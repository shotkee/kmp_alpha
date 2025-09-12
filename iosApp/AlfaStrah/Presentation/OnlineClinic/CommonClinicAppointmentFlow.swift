//
//  CommonClinicAppointmentFlow.swift
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 07/08/2018.
//  Copyright © 2018 RedMadRobot. All rights reserved.
//

import UIKit
import Legacy
import CoreLocation

// swiftlint:disable file_length

class CommonClinicAppointmentFlow: BaseFlow,
                                   ClinicsServiceDependency,
                                   CalendarServiceDependency,
                                   NotificationsServiceDependency,
                                   AccountServiceDependency,
                                   GeolocationServiceDependency,
								   InsurancesServiceDependency {
    private let storyboard = UIStoryboard(name: "OnlineClinins", bundle: nil)

    var accountService: AccountService!
    
    private var clinic: Clinic?
    private var insurance: Insurance!

    var clinicsService: ClinicsService!
    var calendarService: CalendarService!
    var notificationsService: NotificationsService!
    var applicationFlow: ApplicationFlow = ApplicationFlow.shared
    var geoLocationService: GeoLocationService!
	var insurancesService: InsurancesService!

    private let imageLoader: ImageLoader = {
        let http = UrlSessionHttp(
            configuration: .default,
            responseQueue: DispatchQueue.global(qos: .default),
            logger: PrintLogger(),
            loggerTag: "OnlineClinicAppointmentFlow imageLoader"
        )
        return CachingImageLoader(name: "OnlineClinicAppointmentFlow", imageLoader: HttpImageLoader(http: http))
    }()
    
    private lazy var coordinateHandler: CoordinateHandler = {
        let handler = CoordinateHandler()
        container?.resolve(handler)
        return handler
    }()

    private var notifyChanges: [(_ reload: Bool) -> Void] = []

    private func notifyUpdate(reload: Bool) {
        notifyChanges.forEach { $0(reload) }
    }
    
    private var selectedDate = Date()
    private var startScheduleDate: Date?

    /// Start flow to create online doctor appointment for insurance
    func start(clinic: Clinic, insurance: Insurance) {
        self.clinic = clinic
        self.insurance = insurance
        doctorSpecialityPicker()
        logger?.debug("")
    }

    /// Start flow and create AppointmentsListViewController
    func start(insurance: Insurance) -> AppointmentsListViewController {
        self.insurance = insurance
        logger?.debug("")
        return appointmentsList()
    }
    
    /// Show doctor appointment info screen
    func createOnlineDoctorAppointment(clinic: Clinic) {
        self.clinic = clinic
        doctorSpecialityPicker()
        logger?.debug("")
    }
    
    /// Start flow and show doctor appointment info screen
    func start(futureDoctorVisitId id: String, insurance: Insurance, mode: ViewControllerShowMode) {
        self.insurance = insurance
        appointmentInfo(doctorVisitKind: .doctorVisitId(id), mode: mode)
        logger?.debug("")
    }
	
	func start(avisAppointmentId id: String, insurance: Insurance, mode: ViewControllerShowMode) {
		self.insurance = insurance
		appointmentInfo(doctorVisitKind: .avisAppointmentId(insurance.id, id), mode: mode)
		logger?.debug("")
	}

    // MARK: - Error handle

    private func show(error: Error) {
        ErrorHelper.show(error: error, alertPresenter: alertPresenter)
    }

    // MARK: - Appointments list

    private var appointmentsListData: NetworkData<AppointmentsListViewController.VisitsData> = .loading
 
    private func appointmentsList() -> AppointmentsListViewController {
        let viewController: AppointmentsListViewController = storyboard.instantiate()
        
        container?.resolve(viewController)
        
        viewController.input = AppointmentsListViewController.Input(
            data: { self.appointmentsListData },
            imageLoader: imageLoader
        )
        
        viewController.output = AppointmentsListViewController.Output(
            refresh: {
                self.loadAllApointments()
            },
            futureOnlineDoctorVisit: { doctorVisit in
                self.clinic = doctorVisit.clinic
                self.appointmentInfo(doctorVisitKind: .futureDoctorVisit(doctorVisit))
            },
            pastOnlineDoctorVisit: { doctorVisit in
                self.clinic = doctorVisit.clinic
                self.appointmentInfo(doctorVisitKind: .pastDoctorVisit(doctorVisit))
            },
            futureOfflineAvisAppointment: { appointment in
                self.clinic = appointment.clinic
                self.appointmentInfo(doctorVisitKind: .avisFutureAppointment(appointment))
            },
            pastOfflineAvisAppointment: { appointment in
                self.clinic = appointment.clinic
                self.appointmentInfo(doctorVisitKind: .avisPastAppointment(appointment))
            }
        )
        
        notifyChanges.append(viewController.notify.changed)
        
        return viewController
    }

    func loadAllApointments(completion: (() -> Void)? = nil) {
        var futureOnlineDoctorVisits: [DoctorVisit] = []
        var pastOnlineDoctorVisits: [DoctorVisit] = []
        var avisOfflineAppointments: [AVISAppointment] = []
        
        appointmentsListData = .loading
        notifyUpdate(reload: false)

        let group = DispatchGroup()
        var downloadError: Error?

        group.enter()
        clinicsService.futureAppointments(
            insuranceId: insurance.id
        ) { [weak self] result in
            guard let self = self
            else { return }

            switch result {
                case .success(let doctorVisits):
                    futureOnlineDoctorVisits = doctorVisits
                case .failure(let error):
                    self.show(error: error)
                    self.appointmentsListData = .error(error)
            }
            group.leave()
        }
    
        group.enter()
        clinicsService.pastAppointments(
            insuranceId: insurance.id,
            offset: 0,
            pageSize: Int.max
        ) { [weak self] result in
            
            guard let self = self
            else { return }

            switch result {
                case .success(let doctorVisitsResponse):
                    pastOnlineDoctorVisits = doctorVisitsResponse.visits
                case .failure(let error):
                    self.show(error: error)
                    downloadError = error
            }
            group.leave()
        }
        
        group.enter()
        clinicsService.offlineAppointmentsAVIS(
            byInsuranceId: insurance.id
        ) { [weak self] result in
            
            guard let self = self
            else { return }
            
            switch result {
                case .success(let avisAppointments):
                    avisOfflineAppointments = avisAppointments
                case .failure(let error):
                    self.show(error: error)
                    self.appointmentsListData = .error(error)
            }
            group.leave()
        }
        
        group.notify(queue: .main) { [weak self] in
            completion?()
            
            guard let self = self
            else { return }
            
            if let error = downloadError {
                self.appointmentsListData = .error(error)
                self.notifyUpdate(reload: true)
                
                return
            }
            
            self.appointmentsListData = .data(
                AppointmentsListViewController.VisitsData(
                    future: futureOnlineDoctorVisits,
                    past: pastOnlineDoctorVisits,
                    offline: avisOfflineAppointments
                )
            )
            self.notifyUpdate(reload: true)
        }
    }
    
    // MARK: - Doctor Picker

    private var specialitiesData: NetworkData<[DoctorSpeciality]> = .loading

    private func loadSpecialities() {
        guard let clinic = clinic else { return }

        specialitiesData = .loading
        notifyUpdate(reload: false)
        clinicsService.specialities(for: clinic.id, insuranceId: insurance.id) { [weak self] result in
            guard let `self` = self else { return }

            switch result {
                case .success(let specialities):
                    self.specialitiesData = .data(specialities)
                case .failure(let error):
                    self.specialitiesData = .error(error)
                    self.show(error: error)
            }
            self.notifyUpdate(reload: true)
        }
    }

    private func doctorSpecialityPicker() {
        let viewController: DoctorSpecialityPickerViewController = storyboard.instantiate()
        container?.resolve(viewController)
        // swiftlint:disable:next trailing_closure
        viewController.input = DoctorSpecialityPickerViewController.Input(
            data: {
                self.specialitiesData
            }
        )
        viewController.output = DoctorSpecialityPickerViewController.Output(
            selected: { speciality in
                self.doctorPicker(for: speciality, futureDoctorVisit: nil)
            },
            refresh: {
                self.loadSpecialities()
            }
        )
        notifyChanges.append(viewController.notify.changed)
        createAndShowNavigationController(viewController: viewController, mode: .push)
    }

    private var doctorsData: NetworkData<[FullDoctor]> = .loading
    private var selectedDoctor: FullDoctor?
    private var selectedScheduleInterval: DoctorScheduleInterval?

    private func loadDoctors(
        for speciality: DoctorSpeciality,
        _ completion: @escaping (Result<[FullDoctor], AlfastrahError>) -> Void
    ) {
        guard let clinic = clinic else { return }

        doctorsData = .loading
        notifyUpdate(reload: false)
        clinicsService.doctors(
            for: clinic.id,
            insuranceId: insurance.id,
            specialityId: speciality.id,
            for: selectedDate
        ) { [weak self] result in
            guard let self = self
            else { return }

            completion(result)
            
            switch result {
                case .success(let doctors):
                    self.doctorsData = .data(doctors)
                case .failure(let error):
                    self.doctorsData = .error(error)
                    self.show(error: error)
            }
            self.notifyUpdate(reload: true)
        }
    }

    private func loadFullDoctor(
        in clinic: Clinic,
        doctor: ShortDoctor,
        speciality: DoctorSpeciality,
        insuranceId: String,
        scheduleStartDate: Date,
        scheduleEndDate: Date
    ) {
        fullDoctorData = .loading
        notifyUpdate(reload: false)
        
        clinicsService.doctor(
            id: doctor.id,
            clinicId: clinic.id,
            specialityId: speciality.id,
            insuranceId: insuranceId,
            scheduleStartDate: scheduleStartDate,
            scheduleEndDate: scheduleEndDate
        ) { result in
            switch result {
                case .success(let doctor):
                    self.fullDoctorData = .data(doctor)
                case .failure(let error):
                    self.fullDoctorData = .error(error)
                    self.show(error: error)
            }
            self.notifyUpdate(reload: true)
        }
    }

    private func resetSelectedData() {
        selectedScheduleInterval = nil
        selectedDoctor = nil
        startScheduleDate = nil
        selectedDate = Date()
    }

    private func doctorPicker(for speciality: DoctorSpeciality, futureDoctorVisit: DoctorVisit?) {
        let now = Date()
        // reset when picker start again
        selectedDate = now
        startScheduleDate = now
        
        func updateDoctors(for selectedDate: Date, on viewController: DoctorPickerViewController) {
            viewController.notify.updateWithState(.loading)
            
            self.loadDoctors(for: speciality) { [weak viewController] result in
                guard let viewController = viewController
                else { return }

                switch result {
                    case .success(let doctors):
                        viewController.notify.updateWithState(.data(doctors, selectedDate))
                    case .failure:
                        viewController.notify.updateWithState(.failure)
                }
            }
        }
        
        let viewController = DoctorPickerViewController()
        container?.resolve(viewController)
        
        viewController.input = .init(
            speciality: speciality,
            load: { [weak viewController] in
                guard let viewController = viewController
                else { return }
                
                viewController.notify.updateWithState(.loading)
            },
            appear: { [weak viewController] in
                guard let viewController = viewController
                else { return }
                
                updateDoctors(for: self.selectedDate, on: viewController)
            },
            selectedIntervalId: {
                self.selectedScheduleInterval?.id
            }
        )
        
        viewController.output = .init(
            calendar: { [weak viewController] completion in
                self.doctorCalendarFilter { [weak viewController] in
                    guard let viewController = viewController
                    else { return }
                    
                    completion(self.selectedDate)
                    
                    updateDoctors(for: self.selectedDate, on: viewController)
                }
            },
            doctor: { doctor in
                self.selectedDoctor = doctor
                
                guard let clinic = self.clinic
                else { return }
                
                self.doctorTimePicker(
                    for: self.selectedDate,
                    clinic: clinic,
                    doctor: doctor.shortDoctor,
                    showDoctorPicker: false
                )
            },
            scheduleInterval: { scheduleInterval, doctor in
                self.selectedScheduleInterval = scheduleInterval
                self.selectedDoctor = doctor
                self.notifyUpdate(reload: false)
                
                self.showConfirmAppointmentController()
            },
            retry: { [weak viewController] in
                guard let viewController = viewController
                else { return }
                
                updateDoctors(for: self.selectedDate, on: viewController)
            },
            goToChat: {
                ApplicationFlow.shared.show(item: .tabBar(.chat))
            },
            doctorsListForDate: { selectedDate, startScheduleDate in
                self.selectedDate = selectedDate
                self.startScheduleDate = startScheduleDate
                
                updateDoctors(for: self.selectedDate, on: viewController)
            }
        )
        
        createAndShowNavigationController(viewController: viewController, mode: .push)
    }
    
    private func showConfirmAppointmentController(with updatedFutureDoctorVisit: DoctorVisit? = nil) {
        guard let selectedClinic = self.clinic,
              let selectedDoctor = self.selectedDoctor,
              let selectedScheduleInterval = self.selectedScheduleInterval
        else { return }
        
        let viewController = ConfirmAppointmentViewController()
        container?.resolve(viewController)
        
        viewController.input = .init(
            clinic: selectedClinic,
            doctor: selectedDoctor,
            scheduleInterval: selectedScheduleInterval,
            appear: { [weak viewController] in
                guard let viewController = viewController
                else { return }
                
                viewController.notify.update(.data)
            }
        )
        
        viewController.output = .init(
            confirmAppointment: { [weak viewController] in
                guard let viewController = viewController
                else { return }
                
                if let updatedFutureDoctorVisit = updatedFutureDoctorVisit {
                    self.updateOnlineAppointment(
                        updatedFutureDoctorVisit,
                        selectedScheduleInterval,
                        from: viewController
                    )
                } else {
                    self.createOlineAppointment(
                        selectedClinic,
                        selectedDoctor,
                        selectedScheduleInterval,
                        from: viewController
                    )
                }
            },
            done: { [weak viewController] in
                if updatedFutureDoctorVisit == nil { // from main screen
                    if let navigationController = self.navigationController {
                        // if several dms insurances in section return to insurances selection
                        if let selectInsuranceViewController = navigationController.viewControllers.first as? SelectInsuranceViewController {
                            navigationController.setViewControllers([selectInsuranceViewController], animated: true)
                            return
                        }
                        // if only one dms incurance in section return to main screen
                        navigationController.dismiss(animated: true)
                    }
                } else { // from appoinment list
                    guard let viewController = viewController
                    else { return }
                    
                    self.handleConfirmAppointment(from: viewController)
                }
            },
            chooseAnotherTimeInterval: {
                if let navigationController = self.navigationController {
                    navigationController.popViewController(animated: true)
                }
            }
        )
        
        createAndShowNavigationController(viewController: viewController, mode: .push)
    }
    
    private func createOlineAppointment(
        _ selectedClinic: Clinic,
        _ selectedDoctor: FullDoctor,
        _ selectedScheduleInterval: DoctorScheduleInterval,
        from viewController: ConfirmAppointmentViewController
    ) {
        viewController.notify.update(.loading)

        let doctorVisit = DoctorVisit(
            id: "",
            clinic: selectedClinic,
            doctor: selectedDoctor.shortDoctor,
            doctorScheduleInterval: selectedScheduleInterval,
            insuranceId: self.insurance.id,
			alertMessage: "",
			status: nil
        )

        self.clinicsService.createAppointment(doctorVisit) { [weak viewController] result in
            guard let viewController = viewController
            else { return }

            switch result {
                case .success:
                    viewController.notify.update(.success)
                case .failure(let error):
                    if let message = error.message {
                        viewController.notify.update(
                            .failure(
                                title: NSLocalizedString("clinic_appointment_status_appointment_creation_error", comment: ""),
                                description: message
                            )
                        )
                    } else {
                        viewController.notify.update(.failure(
                            title: NSLocalizedString("common_error_title", comment: ""),
                            description: NSLocalizedString("clinic_appointment_status_appointment_creation_error_description", comment: "")
                        ))
                    }
            }
        }
    }
    
    private func updateOnlineAppointment(
        _ doctorVisit: DoctorVisit,
        _ selectedScheduleInterval: DoctorScheduleInterval,
        from viewController: ConfirmAppointmentViewController
    ) {
        var doctorVisitWithUpdatedSelectedScheduleInterval = doctorVisit
        doctorVisitWithUpdatedSelectedScheduleInterval.doctor = self.selectedDoctor?.shortDoctor ?? doctorVisit.doctor
        doctorVisitWithUpdatedSelectedScheduleInterval.doctorScheduleInterval = self.selectedScheduleInterval ?? doctorVisit.doctorScheduleInterval
  
        viewController.notify.update(.loading)
        clinicsService.updateAppointment(doctorVisitWithUpdatedSelectedScheduleInterval) { result in
            switch result {
                case .success:
                    viewController.notify.update(.success)
                case .failure(let error):
                    if let message = error.message {
                        viewController.notify.update(
                            .failure(
                                title: NSLocalizedString("clinic_appointment_status_appointment_creation_error", comment: ""),
                                description: message
                            )
                        )
                    } else {
                        viewController.notify.update(.failure(
                            title: NSLocalizedString("common_error_title", comment: ""),
                            description: NSLocalizedString("clinic_appointment_status_appointment_creation_error_description", comment: "")
                        ))
                    }
            }
        }
    }
    
    private func doctorCalendarFilter(_ completion: @escaping () -> Void) {
        let viewController = DoctorCalendarFilterViewController()
        
        let now = Date()
        
        let startOfDayForNow = AppLocale.calendar.date(
            from: AppLocale.calendar.dateComponents([.year, .month, .day], from: AppLocale.calendar.startOfDay(for: now))
        ) ?? now
        
        viewController.input = .init(
            selectedDate: { return self.selectedDate }(),
            startDate: startOfDayForNow,
            endDate: AppLocale.calendar.date(byAdding: .year, value: 1, to: startOfDayForNow) ?? startOfDayForNow
        )
        
        viewController.output = .init(
            selectedDate: { date in
                if self.selectedDate != date {
                    self.selectedDate = date
                    self.startScheduleDate = date
                    completion()
                }
                
                viewController.dismiss(animated: true)
            }
        )
        
        viewController.addCloseButton { [weak viewController] in
            viewController?.dismiss(animated: true, completion: nil)
        }
        
        createAndShowNavigationController(viewController: viewController, mode: .modal)
    }

    private var fullDoctorData: NetworkData<FullDoctor> = .loading

    private func doctorTimePicker(
        for date: Date,
        clinic: Clinic,
        doctor: ShortDoctor,
        updatedFutureDoctorVisit: DoctorVisit? = nil,
        showDoctorPicker: Bool
    ) {
        let scheduleStartDate = startScheduleDate ?? date
        
        guard let twoWeekShiftToSelectedDate = AppLocale.calendar.date(byAdding: .weekOfYear, value: 2, to: scheduleStartDate)
        else { return }
        
        loadFullDoctor(
            in: clinic,
            doctor: doctor,
            speciality: doctor.speciality,
            insuranceId: insurance.id,
            scheduleStartDate: scheduleStartDate,
            scheduleEndDate: twoWeekShiftToSelectedDate
        )
        
        let viewController: DoctorTimePickerViewController = storyboard.instantiate()
        container?.resolve(viewController)
        
        viewController.input = .init(
            selectedDate: {
                return self.selectedDate
            },
            startScheduleDate: {
                return self.startScheduleDate
            },
            data: { self.fullDoctorData },
            canCreateAppointment: { self.selectedScheduleInterval != nil && self.selectedDoctor != nil },
            showDoctorPicker: showDoctorPicker
        )
        
        viewController.output = .init(
            scheduleInterval: { scheduleInterval, doctor in
                self.selectedScheduleInterval = scheduleInterval
                self.selectedDoctor = doctor
                self.notifyUpdate(reload: false)
            },
            doctorPicker: { speciality in
                self.doctorPicker(for: speciality, futureDoctorVisit: updatedFutureDoctorVisit)
            },
            calendar: { [weak viewController] completion in
                self.doctorCalendarFilter { [weak viewController] in
                    guard let viewController = viewController
                    else { return }
                    
                    completion(self.selectedDate)
                    
                    guard let twoWeekShiftToSelectedDate = AppLocale.calendar.date(byAdding: .weekOfYear, value: 2, to: self.selectedDate)
                    else { return }
                                        
                    self.loadFullDoctor(
                        in: clinic,
                        doctor: doctor,
                        speciality: doctor.speciality,
                        insuranceId: self.insurance.id,
                        scheduleStartDate: self.selectedDate,
                        scheduleEndDate: twoWeekShiftToSelectedDate
                    )
                }
            },
            goToChat: {
                ApplicationFlow.shared.show(item: .tabBar(.chat))
            },
            retry: {
                self.loadFullDoctor(
                    in: clinic,
                    doctor: doctor,
                    speciality: doctor.speciality,
                    insuranceId: self.insurance.id,
                    scheduleStartDate: self.selectedDate,
                    scheduleEndDate: self.selectedDate
                )
            },
            confirmAppointment: { scheduleInterval, doctor in
                self.selectedScheduleInterval = scheduleInterval
                self.selectedDoctor = doctor
                
                self.showConfirmAppointmentController(with: updatedFutureDoctorVisit)
            },
            selectedDateChanged: { selectedDate in
                self.selectedDate = selectedDate
            }
        )

        notifyChanges.append(viewController.notify.changed)
        createAndShowNavigationController(viewController: viewController, mode: .push)
    }

    // MARK: - Appointment Summary

    private enum AppointmentKind {
        case futureDoctorVisit(DoctorVisit)
        case pastDoctorVisit(DoctorVisit)
        case avisFutureAppointment(AVISAppointment)
        case avisPastAppointment(AVISAppointment)
        case notConfirmed(DoctorVisit, update: Bool)
        case doctorVisitId(String)
		case avisAppointmentId(_ insuranceId: String, _ appointmentId: String)
    }

    private var appointmentInfoData: NetworkData<CommonAppointmentInfoViewController.AppointmentOperationKind> = .loading

    private func appointmentInfo(doctorVisitKind: AppointmentKind, mode: ViewControllerShowMode = .push) {
        let viewController: CommonAppointmentInfoViewController = storyboard.instantiate()
        container?.resolve(viewController)
        // swiftlint:disable:next trailing_closure
        viewController.input = CommonAppointmentInfoViewController.Input(
            data: {
                self.appointmentInfoData
            }
        )
        // swiftlint:disable:next trailing_closure
        viewController.output = CommonAppointmentInfoViewController.Output(
			clinicInfo: { kind in
				self.clinicInfo(kind: kind, navigationSource: .appointmentInfo)
			},
            phone: phone,
            route: routeInAnotherApp,
            createCalendarEvent: createCalendarEvent,
            confirmAppointment: confirmOnlineAppointment,
            cancelAppointment: cancelAppointment,
            changeAppointment: changeAppointment,
            refresh: {
                switch doctorVisitKind {
                    case .futureDoctorVisit(let doctorVisit):
                        self.appointmentInfoData = .data(.futureOnlineAppointment(doctorVisit))
                        self.notifyUpdate(reload: true)
                    case .pastDoctorVisit(let doctorVisit):
                        self.appointmentInfoData = .data(.pastOnlineAppointment(doctorVisit))
                        self.notifyUpdate(reload: true)
                    case .avisFutureAppointment(let appointment):
                        self.appointmentInfoData = .data(.avisOfflineFutureAppointment(appointment, nil, create: false))
                        self.notifyUpdate(reload: true)
                    case .avisPastAppointment(let appointment):
                        self.appointmentInfoData = .data(.avisOfflinePastAppointment(appointment))
                        self.notifyUpdate(reload: true)
                    case .notConfirmed(let doctorVisit, let update):
                        self.appointmentInfoData = .data(.confirmOnlineAppointment(doctorVisit, update: update))
                        self.notifyUpdate(reload: true)
                    case .doctorVisitId(let id):
                        self.loadDoctorVisit(id: id)
					case .avisAppointmentId(let insuranceId, let appointmentId):
						self.loadAppointment(with: appointmentId, for: insuranceId)
                }
            },
            clinicWebAddressTap: { [weak viewController] url in
                guard let viewController = viewController
                else { return }

                SafariViewController.open(url, from: viewController)
            }
        )

        notifyChanges.append(viewController.notify.changed)
        if mode == .modal {
            viewController.addCloseButton { [weak viewController] in
                viewController?.dismiss(animated: true, completion: nil)
            }
        }
        createAndShowNavigationController(viewController: viewController, mode: mode)
    }

    private func loadDoctorVisit(id: String) {
        appointmentInfoData = .loading
        notifyUpdate(reload: false)
        clinicsService.appointment(id: id) { result in
            switch result {
                case .success(let doctorVisit):
                    self.clinic = doctorVisit.clinic
                    self.appointmentInfoData = .data(.futureOnlineAppointment(doctorVisit))
                case .failure(let error):
                    self.appointmentInfoData = .error(error)
                    self.show(error: error)
            }
            self.notifyUpdate(reload: true)
        }
    }
	
	private func loadAppointment(with id: String, for insuranceId: String) {
		appointmentInfoData = .loading
		notifyUpdate(reload: false)
		
		clinicsService.offlineAppointmentsAVIS(byInsuranceId: insuranceId) { result in
			switch result {
				case .success(let appointmentList):
					if let appointment = appointmentList.first(where: {
						String($0.id) == id
					}) {
						self.clinic = appointment.clinic
						self.appointmentInfoData = .data(.avisOfflineFutureAppointment(appointment, nil, create: false))
					} else {
						let error = AlfastrahError.unknownError
						
						self.appointmentInfoData = .error(error)
						self.show(error: error)
					}
													 
				case .failure(let error):
					self.appointmentInfoData = .error(error)
					self.show(error: error)
													 
			}
			
			self.notifyUpdate(reload: true)
		}
	}

    private func confirmOnlineAppointment(
        kind: CommonAppointmentInfoViewController.AppointmentOperationKind,
        update: Bool
    ) {
        switch kind {
            case .confirmOnlineAppointment(let doctorVisit, let update):
                appointmentStatusInfoScreen(kind: .onlineAppointmentCreate) { [weak self] in
                    self?.createAppointmentRequest(doctorVisit: doctorVisit, update: update)
                }
            case .futureOnlineAppointment,
                .pastOnlineAppointment,
                .avisOfflineFutureAppointment,
                .avisOfflinePastAppointment:
                return
        }
    }
    
    private lazy var cancelAppointmentdateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = NSLocalizedString("clinic_appointment_cancel_date_format", comment: "")
        formatter.locale = AppLocale.currentLocale
        return formatter
    }()

    private func cancelAppointment(
        kind: CommonAppointmentInfoViewController.AppointmentOperationKind
    ) {
        switch kind {
            case .confirmOnlineAppointment,
                .pastOnlineAppointment,
                .avisOfflinePastAppointment:
                return
            case .futureOnlineAppointment(let doctorVisit):
                guard let clinic = doctorVisit.clinic
                else { return }
                
                let dateString = cancelAppointmentdateFormatter.string(from: doctorVisit.doctorScheduleInterval.startDate)
                let message = "\(clinic.title), \(dateString), \(doctorVisit.doctor.speciality.title.lowercased())," +
                    " \(doctorVisit.doctor.title)"
                appointmentStatusInfoScreen(kind: .commonAppointmentCancel(message: message)) { [weak self] in
                    self?.cancelAppointmentRequest(doctorVisit: doctorVisit)
                }
            case .avisOfflineFutureAppointment(let avisAppointment, _, _):
                guard let clinic = avisAppointment.clinic
                else { return }
                
                let dateString = avisAppointment.appointmentDate.map {
                    cancelAppointmentdateFormatter.string(from: $0)
                }
                
                var messageArray = [String]()
                
                messageArray.append(clinic.title)
                if let dateString = dateString {
                    messageArray.append(dateString)
                }
				if let referralOrDepartment = avisAppointment.referralOrDepartment
				{
					messageArray.append(referralOrDepartment.lowercased())
				}
                if let doctorFullName = avisAppointment.doctorFullName {
                    messageArray.append(doctorFullName)
                }
                
                let message = messageArray.joined(separator: ", ")
                
                appointmentStatusInfoScreen(kind: .commonAppointmentCancel(message: message)) { [weak self] in
                    
                    guard let self = self
                    else { return }
                    
                    self.cancelAvisAppointment(
                        with: avisAppointment.id,
                        for: self.insurance.id
                    )
                }
        }
    }

    private func changeAppointment(
        kind: CommonAppointmentInfoViewController.AppointmentOperationKind
    ) {
        switch kind {
            case .confirmOnlineAppointment,
                .pastOnlineAppointment,
                .avisOfflinePastAppointment:
                return
            case .futureOnlineAppointment(let doctorVisit):
                resetSelectedData()

                guard let clinic = doctorVisit.clinic
                else { return }

                self.selectedDate = doctorVisit.doctorScheduleInterval.date
                
                doctorTimePicker(
                    for: doctorVisit.doctorScheduleInterval.date,
                    clinic: clinic,
                    doctor: doctorVisit.doctor,
                    updatedFutureDoctorVisit: doctorVisit,
                    showDoctorPicker: true
                )
                                    
            case .avisOfflineFutureAppointment(let avisAppointment, _, let create):
                guard let topController = self.navigationController?.visibleViewController,
                      let clinic = avisAppointment.clinic
                else { return }

                let hide = topController.showLoadingIndicator(message: nil)

                clinicsService.offlineAppointmentSettings(
                    for: clinic.id
                ) { [weak self] result in
                    hide(nil)

                    guard let self = self
                    else { return }

                    switch result {
                        case .success(let settings):
                            self.createOfflineAppointment(
                                kind: .avisOfflineFutureAppointment(
                                    avisAppointment,
                                    settings,
                                    create: create
                                )
                            )
                        case .failure(let error):
                            let viewController = topController as? ViewController

                            guard let viewController = viewController
                            else { return }
                            viewController.processError(error)
                    }
                }
        }
    }
    
    private func cancelAvisAppointment(with id: Int, for insuranceId: String) {
        appointmentStatusInfoData = .loading
        notifyUpdate(reload: false)
        clinicsService.cancelOfflineAppointmentAVIS(id: id, insuranceId: insuranceId) {
            [weak self] result in
            
            guard let self = self
            else { return }
            
            switch result {
                case .success:
                    self.appointmentStatusInfoData = .data(true)
                case .failure(let error):
                    self.appointmentStatusInfoData = .error(error)
                    self.show(error: error)
            }
            self.notifyUpdate(reload: true)
        }
    }
    
    // MARK: - Appointment status info

    private var appointmentStatusInfoData: NetworkData<Bool> = .loading

    private func appointmentStatusInfoScreen(kind: ClinicAppointmentStatusViewController.Kind, operationRequest: @escaping () -> Void) {
        let viewController: ClinicAppointmentStatusViewController = storyboard.instantiate()
        // swiftlint:disable:next trailing_closure
        viewController.input = ClinicAppointmentStatusViewController.Input(
            kind: kind,
            data: { self.appointmentStatusInfoData }
        )
        viewController.output = ClinicAppointmentStatusViewController.Output(
            refresh: {
                operationRequest()
            },
            doneTap: { [weak viewController] in
                guard let viewController = viewController
                else { return }
                
                self.handleConfirmAppointment(from: viewController)
            }
        )
        
        viewController.navigationItem.setHidesBackButton(true, animated: false)
        
        let changed: (_ reload: Bool) -> Void = { [weak viewController] _ in
            viewController?.notify.changed()
        }

        notifyChanges.append(changed)
        
        createAndShowNavigationController(
            viewController: viewController,
            mode: .push,
            asInitial: false
        )
    }
    
    private func handleConfirmAppointment(from viewController: ViewController) {
        guard let navigationController = self.navigationController
        else { return }
                        
        self.navigationController?.viewControllers.removeAll(where: { viewController -> Bool in
            if viewController.isKind(of: CommonAppointmentInfoViewController.self)
            || viewController.isKind(of: DoctorPickerViewController.self)
            || viewController.isKind(of: DoctorSpecialityPickerViewController.self)
            || viewController.isKind(of: ClinicViewController.self)
            || viewController.isKind(of: ClinicsListViewController.self)
            || viewController.isKind(of: ClinicPickerViewController.self)
            || viewController.isKind(of: DoctorTimePickerViewController.self) {
                return true
            } else {
                return false
            }
        })

        navigationController.popViewController(animated: true)
        
        // if ClinicAppointmentStatusViewController was presented by notification section tap on HomeViewController
        // in this case it need to be dismissed separately
        viewController.dismiss(animated: true)
        
//                if kind == .onlineAppointmentCreate {
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
//                        self.applicationFlow.show(item: .rateApp)
//                    }
//                }

        self.loadAllApointments()
    }
    
    private func createAppointmentRequest(doctorVisit: DoctorVisit, update: Bool) {
        appointmentStatusInfoData = .loading
        notifyUpdate(reload: false)

        let completion: (Result<Void, AlfastrahError>) -> Void = { [weak self] result in
            guard let self = self,
                  let clinic = doctorVisit.clinic
            else { return }

            switch result {
                case .success:
					if let analyticsData = analyticsData(
						from: self.insurancesService.cachedShortInsurances(forced: true),
						for: insurance.id
					) {
						self.analytics.track(
							insuranceId: insurance.id,
							event: AnalyticsEvent.Clinic.onlineAppointmentDone,
							userProfileProperties: analyticsData.analyticsUserProfileProperties
						)
					}
					
                    self.appointmentStatusInfoData = .data(true)
                    self.notificationsService.notify.needRefreshNotifications()
					
                case .failure(let error):
					if let analyticsData = analyticsData(
						from: self.insurancesService.cachedShortInsurances(forced: true),
						for: insurance.id
					) {
						self.analytics.track(
							insuranceId: insurance.id,
							event: AnalyticsEvent.Clinic.onlineAppointmentError,
							userProfileProperties: analyticsData.analyticsUserProfileProperties
						)
					}
					
                    self.appointmentStatusInfoData = .error(error)
                    self.show(error: error)
					
            }
            self.notifyUpdate(reload: true)
        }

        if update {
            clinicsService.updateAppointment(doctorVisit) { result in
                switch result {
                    case .success:
                        completion(.success(()))
                    case let .failure(error):
                        completion(.failure(error))
                }
            }
        } else {
            clinicsService.createAppointment(doctorVisit, completion: completion)
        }
    }

    private func cancelAppointmentRequest(doctorVisit: DoctorVisit) {
        appointmentStatusInfoData = .loading
        notifyUpdate(reload: false)
        clinicsService.cancelAppointment(doctorVisit) { [weak self] result in
            guard let `self` = self else { return }

            switch result {
                case .success(let success):
                    self.appointmentStatusInfoData = .data(success)
                    self.notificationsService.notify.needRefreshNotifications()
                case .failure(let error):
                    self.appointmentStatusInfoData = .error(error)
                    self.show(error: error)
            }
            self.notifyUpdate(reload: true)
        }
    }
    
    private func createOfflineAppointment(
        kind: CommonAppointmentInfoViewController.AppointmentOperationKind
    ) {
        let clinicFlow = ClinicAppointmentFlow(rootController: topModalController)
        container?.resolve(clinicFlow)
        
        switch kind {
            case.avisOfflineFutureAppointment(let avisAppointment, let settings, let create):
                guard let settings = settings
                else { return }
                
                clinicFlow.start(
                    from: self,
                    with: insurance,
                    avisAppointment: avisAppointment,
                    settings: settings,
                    create: create
                )
            default:
                return
        }
    }

    // MARK: - Helpers
    private func clinicInfo(
		kind: CommonAppointmentInfoViewController.AppointmentOperationKind,
		navigationSource: AnalyticsParam.NavigationSource
	) {
        let clinicFlow = ClinicAppointmentFlow(rootController: topModalController)
        container?.resolve(clinicFlow)
        switch kind {
            case .confirmOnlineAppointment:
                break
            case .futureOnlineAppointment(let doctorVisit),
                    .pastOnlineAppointment(let doctorVisit):
                guard let clinic = doctorVisit.clinic
                else { return }
                
                clinicFlow.start(
                    clinicKind: .info(clinic),
                    insurance: insurance,
					navigationSource: navigationSource
                )
            case .avisOfflineFutureAppointment(let avisAppointment, _, _),
                    .avisOfflinePastAppointment(let avisAppointment):
                guard let clinic = avisAppointment.clinic
                else { return }
                clinicFlow.start(
                    clinicKind: .appointment(clinic),
                    insurance: insurance,
					navigationSource: navigationSource
                )
        }
    }
    
    private func route(_ coordinate: CLLocationCoordinate2D, title: String?) {
        CoordinateHandler.handleCoordinate(coordinate, title: title)
    }
    
    private func routeInAnotherApp(_ coordinate: CLLocationCoordinate2D, title: String?) {
        guard let currentPosition = geoLocationService.lastLocation
        else { return }

        coordinateHandler.handleCoordinateToOpenApps(coordinate, title: title, current: currentPosition)
    }

    private func phone(_ phone: Phone) {
        PhoneHelper.handlePhone(plain: phone.plain, humanReadable: phone.humanReadable)
    }
    
    private func createCalendarEvent(
        kind: CommonAppointmentInfoViewController.AppointmentOperationKind
    ) {
		func showCalendarAlert() {
			DispatchQueue.main.async { [weak self] in
				if let rootViewController = self?.navigationController {
					let controller = UIHelper.findTopModal(controller: rootViewController)
					UIHelper.showCalendarRequiredAlert(from: controller)
				}
			}
		}
		
        switch kind {
            case .confirmOnlineAppointment,
                .pastOnlineAppointment,
                .avisOfflinePastAppointment:
                return
            case .futureOnlineAppointment(let doctorVisit):
                guard let clinic = doctorVisit.clinic
                else { return }
                
                calendarService.createEvent(
                    title: NSLocalizedString("calendar_doctor_event_title", comment: ""),
                    notes: nil,
                    startDate: doctorVisit.doctorScheduleInterval.startDate,
                    endDate: doctorVisit.doctorScheduleInterval.endDate,
                    isAllDay: false,
                    locationTitle: clinic.title,
                    address: clinic.address,
                    location: clinic.coordinate.clLocation
                ) { [weak self] result in
                    guard let `self` = self else { return }

                    switch result {
                        case .success:
                            DispatchQueue.main.async {
                                let text = NSLocalizedString("calendar_event_created", comment: "")
                                self.alertPresenter.show(alert: AddCalendarNotificationAlert(text: text))
                            }
                        case .failure(let error):
                            switch error {
                                case .accessDenied:
									showCalendarAlert()
                                case .dateInPast, .error:
                                    self.show(error: error)
                            }
                    }
                }
            case .avisOfflineFutureAppointment(let appointment, _, _):
                guard let clinic = appointment.clinic
                else { return }

                let date = appointment.localDate.date
                
                calendarService.createEvent(
                    title: NSLocalizedString("calendar_doctor_event_title", comment: ""),
                    notes: nil,
                    startDate: date,
                    endDate: date,
                    isAllDay: false,
                    locationTitle: clinic.title,
                    address: clinic.address,
                    location: clinic.coordinate.clLocation
                ) { [weak self] result in
                    guard let self = self
                    else { return }

                    switch result {
                        case .success:
                            DispatchQueue.main.async {
                                let text = NSLocalizedString("calendar_event_created", comment: "")
                                self.alertPresenter.show(alert: AddCalendarNotificationAlert(text: text))
                            }
                        case .failure(let error):
                            switch error {
                                case .accessDenied:
									showCalendarAlert()
                                case .dateInPast, .error:
                                    self.show(error: error)
                            }
                    }
                }
        }
    }
}

// swiftlint:enable trailing_closure
