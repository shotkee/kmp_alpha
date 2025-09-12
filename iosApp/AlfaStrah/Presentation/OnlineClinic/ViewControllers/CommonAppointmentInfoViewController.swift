//
//  CommonAppointmentInfoViewController.swift
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 07/08/2018.
//  Copyright © 2018 RedMadRobot. All rights reserved.
//

import UIKit
import Legacy
import CoreLocation

final class CommonAppointmentInfoViewController: ViewController {
    enum AppointmentOperationKind {
        case confirmOnlineAppointment(DoctorVisit, update: Bool)
        case futureOnlineAppointment(DoctorVisit)
        case pastOnlineAppointment(DoctorVisit)
        case avisOfflineFutureAppointment(
            AVISAppointment,
            OfflineAppointmentSettings?,
            create: Bool
        )
        case avisOfflinePastAppointment(AVISAppointment)

        var update: Bool {
            switch self {
                case .confirmOnlineAppointment(_, let update):
                    return update
                case .futureOnlineAppointment,
                    .pastOnlineAppointment,
                    .avisOfflineFutureAppointment,
                    .avisOfflinePastAppointment:
                    return false
            }
        }
    }
    
    struct Input {
        var data: () -> NetworkData<AppointmentOperationKind>
    }

    struct Output {
		var clinicInfo: (AppointmentOperationKind) -> Void
        var phone: (Phone) -> Void
        var route: (CLLocationCoordinate2D, _ title: String?) -> Void
        var createCalendarEvent: (AppointmentOperationKind) -> Void
        var confirmAppointment: (AppointmentOperationKind, _ update: Bool) -> Void
        var cancelAppointment: (AppointmentOperationKind) -> Void
        var changeAppointment: (AppointmentOperationKind) -> Void
        var refresh: () -> Void
        var clinicWebAddressTap: (URL) -> Void
    }

    struct Notify {
        var changed: (_ reload: Bool) -> Void
    }

    var input: Input!
    var output: Output!
    // swiftlint:disable:next trailing_closure
    private(set) lazy var notify = Notify(
        changed: { [weak self] reload in
            guard let `self` = self, self.isViewLoaded else { return }

            self.update(reload: reload)
        }
    )

    @IBOutlet private var scrollView: UIScrollView!
    @IBOutlet private var stackView: UIStackView!
    @IBOutlet private var actionButtonsStackView: UIStackView!

    private lazy var utcDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM yyyy, HH:mm"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        formatter.locale = AppLocale.currentLocale
        return formatter
    }()
    
    private lazy var localDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM yyyy, HH:mm"
        formatter.locale = AppLocale.currentLocale
        return formatter
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        output.refresh()
    }
    
    override func viewDidLayoutSubviews() {
        scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: actionButtonsStackView.frame.height, right: 0)
    }

    // MARK: - Setup UI

    private func setup() {
		view.backgroundColor = .Background.backgroundContent
		
        addZeroView()
    }

    private func update(reload: Bool) {
        switch input.data() {
            case .loading:
                zeroView?.update(viewModel: .init(kind: .loading))
                showZeroView()
            case .data(let kind):
                appointmentOperationKind = kind
                if reload {
                    updateInfo(kind: kind)
                }
                hideZeroView()
            case .error(let error):
                let zeroViewModel = ZeroViewModel(
                    kind: .error(error, retry: .init(kind: .always, action: { [weak self] in self?.output.refresh() }))
                )
                zeroView?.update(viewModel: zeroViewModel)
                showZeroView()
        }
    }

    private var appointmentOperationKind: AppointmentOperationKind?

    private func updateInfo(kind: AppointmentOperationKind) {
        stackView.subviews.forEach { $0.removeFromSuperview() }
        actionButtonsStackView.subviews.forEach { $0.removeFromSuperview() }

        switch kind {
            case .confirmOnlineAppointment(let doctorVisit, _):
                guard let clinic = doctorVisit.clinic
                else { return }
                
                title = NSLocalizedString("clinic_appointment_online_create_title", comment: "")
                addAddressInfo(interactive: false, for: clinic)
                addDoctorName(doctorVisit.doctor.title)
                addDoctorAdditionalInfo(doctorVisit.doctor.speciality.title, kind: kind)
                addPhonesInfo(interactive: false, for: clinic)
                addAppointmentTimeInfo(date: doctorVisit.doctorScheduleInterval.startDate, dateFormatter: localDateFormatter)
                addConfirmAppointmentButton()
                addClinicInfo(interactive: false, kind: kind)
            case .futureOnlineAppointment(let doctorVisit):
                guard let clinic = doctorVisit.clinic
                else { return }
                
                title = NSLocalizedString("clinic_appointment_online_edit_title", comment: "")
                
                addAlertMessageInfo(doctorVisit: doctorVisit)
                
                addMapInfo(for: clinic)
                
                addAddressInfo(interactive: true, for: clinic)
                addClinicInfo(kind: kind)
                
                addClinicServiceHoursInfo(clinic.serviceHours)
                addAppointmentTimeInfo(date: doctorVisit.doctorScheduleInterval.startDate, dateFormatter: localDateFormatter)

                //addWebAddressInfo(for: clinic)
                
                addCalendarAction()
                
                addDoctorName(doctorVisit.doctor.title)
                addDoctorAdditionalInfo(doctorVisit.doctor.speciality.title, kind: kind)
                
                addPhonesInfo(interactive: true, for: clinic)
                
                addSpaceViewWith(height: 30)
                
                actionButtonsStackView.axis = .vertical
                addChangeAppointmentButton(to: actionButtonsStackView)
                addCancelAppointmentButton(to: actionButtonsStackView)
                
            case .pastOnlineAppointment(let doctorVisit):
                guard let clinic = doctorVisit.clinic
                else { return }
                
                title = localDateFormatter.string(
                    from: doctorVisit.doctorScheduleInterval.startDate
                )
                addClinicInfo(kind: kind)
                addAddressInfo(interactive: false, for: clinic)
                
                addDoctorName(doctorVisit.doctor.title)
                addDoctorAdditionalInfo(doctorVisit.doctor.speciality.title, kind: kind)
                
                //addWebAddressInfo(for: clinic)
                addPhonesInfo(interactive: true, for: clinic)
            case .avisOfflineFutureAppointment(let appointment, _, _):
                guard let clinic = appointment.clinic
                else { return }
                
                if let date = appointment.appointmentDate {
                    title = utcDateFormatter.string(
                        from: date
                    )
                }

                addMapInfo(for: clinic)
                
                addAddressInfo(interactive: true, for: clinic)
                
                switch appointment.clinicType {
                    case .avis:
                        addClinicInfo(interactive: true, kind: kind)
                    case .javis:
                        addClinicInfo(interactive: false, kind: kind)
                }
                
                addClinicServiceHoursInfo(clinic.serviceHours)
                
                addAppointmentTimeInfo(date: appointment.appointmentDate, dateFormatter: utcDateFormatter)
                
                //addWebAddressInfo(for: clinic)
                
                addCalendarAction()
 
                addDoctorName(appointment.doctorFullName)
                addDoctorAdditionalInfo(appointment.referralOrDepartment, kind: kind)
                
                addPhonesInfo(interactive: true, for: clinic)
                
                addSpaceViewWith(height: 30)
                
                actionButtonsStackView.axis = .vertical
                switch appointment.clinicType {
                    case .avis:
                        addChangeAppointmentButton(to: actionButtonsStackView)
                        addCancelAppointmentButton(to: actionButtonsStackView)
                    case .javis:
                        addCancelAppointmentButton(to: actionButtonsStackView)
                }

            case .avisOfflinePastAppointment(let appointment):
                guard let clinic = appointment.clinic
                else { return }
                
                if let date = appointment.appointmentDate {
                    title = utcDateFormatter.string(
                        from: date
                    )
                }
                addClinicInfo(kind: kind)
                addAddressInfo(interactive: false, for: clinic)
                addDoctorName(appointment.doctorFullName)
                addDoctorAdditionalInfo(appointment.referralOrDepartment, kind: kind)
                
                //addWebAddressInfo(for: clinic)
                addPhonesInfo(interactive: true, for: clinic)
        }
    }
    
//    private func addWebAddressInfo(for clinic: Clinic) {
//        guard let clinicWebAddress = clinic.webAddress
//        else { return }
//        
//        let clinicWebAddressView = CommonInfoView.fromNib()
//        let textBlock = CommonInfoView.TextBlock(text: clinicWebAddress.absoluteString) {
//            [weak self] in
//            self?.output.clinicWebAddressTap(clinicWebAddress)
//        }
//        
//        clinicWebAddressView.set(
//            title: NSLocalizedString("info_site", comment: ""),
//            textBlocks: [ textBlock ],
//            appearance: .linkSmallTitleWithoutSeparator
//        )
//
//		stackView.addArrangedSubview(clinicWebAddressView.embedded(margins: Constants.cardInsetsWithShadow, hasShadow: false))
//    }
    
    private func addSpaceViewWith(height: CGFloat) {
        let view = UIView()
        stackView.addArrangedSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate(
            [
                view.heightAnchor.constraint(equalToConstant: height)
            ]
        )
    }
    
    private func addMapInfo(for clinic: Clinic) {
        let containerView = UIView()
        
        let mapView = MapInfoView.fromNib()
        mapView.configureForCoordinate(clinic.coordinate.clLocationCoordinate)
        
        containerView.addSubview(mapView)
        stackView.addArrangedSubview(containerView)
        
        mapView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate(
            [
                mapView.topAnchor.constraint(
                    equalTo: containerView.topAnchor,
                    constant: 0
                ),
                mapView.bottomAnchor.constraint(
                    equalTo: containerView.bottomAnchor,
                    constant: -22
                ),
                mapView.trailingAnchor.constraint(
                    equalTo: containerView.trailingAnchor,
                    constant: 0
                ),
                mapView.leadingAnchor.constraint(
                    equalTo: containerView.leadingAnchor,
                    constant: 0
                ),
                mapView.heightAnchor.constraint(equalToConstant: 200)
            ]
        )
    }
        
    private func addClinicInfo(interactive: Bool = true, kind: AppointmentOperationKind) {
        var clinicTitle = ""
        
        switch kind {
            case .confirmOnlineAppointment(let doctorVisit, _):
                guard let clinic = doctorVisit.clinic
                else { return }
                clinicTitle = clinic.title
            case .futureOnlineAppointment(let doctorVisit),
                .pastOnlineAppointment(let doctorVisit):
                guard let clinic = doctorVisit.clinic
                else { return }
                clinicTitle = clinic.title
            case .avisOfflineFutureAppointment(let avisAppointment, _, _),
                .avisOfflinePastAppointment(let avisAppointment):
                guard let clinic = avisAppointment.clinic
                else { return }
                clinicTitle = clinic.title
        }
        
        let clinicInfoView = CommonInfoView.fromNib()
        let clinicTextBlock = CommonInfoView.TextBlock(text: clinicTitle) {
            [weak self] in
            if interactive {
                self?.output.clinicInfo(kind)
            }
        }
        
        clinicInfoView.set(
            title: NSLocalizedString("clinic_appointment_clinic", comment: ""),
            textBlocks: [ clinicTextBlock ],
            icon: interactive ? UIImage(named: "icon-accessory-arrow-red") : nil,
            appearance: .newRegularWithoutSeparator
        )
        
		clinicInfoView.backgroundColor = .Background.backgroundSecondary
		
		stackView.addArrangedSubview(clinicInfoView.embedded(margins: Constants.cardInsetsWithShadow, hasShadow: true))
    }
    
    private func addAddressInfo(interactive: Bool, for clinic: Clinic) {
        let addressInfoView = CommonInfoView.fromNib()
        let textBlock = CommonInfoView.TextBlock(text: clinic.address) {
            [weak self] in
            
            guard let self = self
            else { return }

            if interactive {
                self.output.route(
                    clinic.coordinate.clLocationCoordinate,
                    clinic.address
                )
            }
        }
        
        addressInfoView.set(
            title: NSLocalizedString("info_address", comment: ""),
            textBlocks: [ textBlock ],
            icon: interactive ? UIImage(named: "icon-route") : nil,
            appearance: .newRegularWithoutSeparator
        )
                
		addressInfoView.backgroundColor = .Background.backgroundSecondary
		
		stackView.addArrangedSubview(addressInfoView.embedded(margins: Constants.cardInsetsWithShadow, hasShadow: true))
    }
        
    private func addDoctorName(_ fullname: String?) {
        guard let fullname = fullname
        else { return }
        
        if !fullname.isEmpty {
            let doctorInfoView = CommonInfoView.fromNib()
            doctorInfoView.set(
                title: NSLocalizedString("clinic_info_doctor", comment: ""),
                textBlocks: [CommonInfoView.TextBlock(text: fullname)],
                appearance: .newRegularWithoutSeparator
            )
			
			stackView.addArrangedSubview(doctorInfoView.embedded(margins: Constants.cardInsetsWithShadow, hasShadow: false))
        }
    }
    
    private func addClinicServiceHoursInfo(_ serviceHoursInfo: String) {
        let clinicServiceHoursInfoView = CommonInfoView.fromNib()
        clinicServiceHoursInfoView.set(
            title: NSLocalizedString("info_open_hours", comment: ""),
            textBlocks: [CommonInfoView.TextBlock(text: serviceHoursInfo)],
            appearance: .newRegularWithoutSeparator
        )

		stackView.addArrangedSubview(clinicServiceHoursInfoView.embedded(margins: Constants.cardInsetsWithShadow, hasShadow: false))
    }

    private func addDoctorAdditionalInfo(_ info: String?, kind: AppointmentOperationKind) {
		guard let info
		else { return }
		
        let positionInfoView = CommonInfoView.fromNib()
        positionInfoView.set(
            title: NSLocalizedString("clinic_info_referral_or_department", comment: ""),
            textBlocks: [CommonInfoView.TextBlock(text: info)],
            appearance: .newRegularWithoutSeparator
        )

		stackView.addArrangedSubview(positionInfoView.embedded(margins: Constants.cardInsetsWithShadow, hasShadow: false))
    }
    
    private func addPhonesInfo(interactive: Bool, for clinic: Clinic) {
        if !(clinic.phoneList ?? []).isEmpty {
            let textBlocks = (clinic.phoneList ?? []).map { phone in
                CommonInfoView.TextBlock(text: phone.humanReadable) { [weak self] in
                    if interactive {
                        self?.output.phone(phone)
                    }
                }
            }
            
            let phoneInfoView = CommonInfoView.fromNib()
            phoneInfoView.set(
                title: NSLocalizedString("clinic_appointment_phone", comment: ""),
                textBlocks: textBlocks,
                icon: interactive ? UIImage(named: "icon-phone") : nil,
                appearance: .newRegularWithoutSeparator
            )
            
			phoneInfoView.backgroundColor = .Background.backgroundSecondary
			
			stackView.addArrangedSubview(phoneInfoView.embedded(margins: Constants.cardInsetsWithShadow, hasShadow: true))
        }
    }
    
    private func addAppointmentTimeInfo(date: Date?, dateFormatter: DateFormatter) {
        guard let date = date
        else { return }
        
        let timeInfoView = CommonInfoView.fromNib()
        timeInfoView.set(
            title: NSLocalizedString("clinic_info_date_and_time", comment: ""),
            textBlocks: [CommonInfoView.TextBlock(text: dateFormatter.string(from: date))],
            appearance: .newRegularWithoutSeparator
        )
		
		stackView.addArrangedSubview(timeInfoView.embedded(margins: Constants.cardInsetsWithShadow, hasShadow: false))
    }
    
    private func addAlertMessageInfo(doctorVisit: DoctorVisit) {
        if let alertMessage = doctorVisit.alertMessage {
            let attentionView = CommonAttentionView()
            attentionView.set(message: alertMessage, appearance: .yellow)
            stackView.addArrangedSubview(attentionView)
        }
    }

    private func addCalendarAction() {
        let textBlock = CommonInfoView.TextBlock(text: NSLocalizedString("info_add_to_calendar", comment: "")) { [weak self] in
            
            guard let kind = self?.appointmentOperationKind
            else { return }

            self?.output.createCalendarEvent(kind)
        }

        let calendarInfoView = CommonInfoView.fromNib()
        calendarInfoView.set(
            title: nil,
            textBlocks: [ textBlock ], icon: UIImage(named: "icon-add-calendar"),
            appearance: .newMediumWithoutSeparator
        )

		calendarInfoView.backgroundColor = .Background.backgroundSecondary
		
		stackView.addArrangedSubview(calendarInfoView.embedded(margins: Constants.cardInsetsWithShadow, hasShadow: true))
    }

    private func addConfirmAppointmentButton() {
        let confirmAppointmentButton = RoundEdgeButton()
		confirmAppointmentButton.setTitle(NSLocalizedString( NSLocalizedString("clinic_confirm", comment: ""), comment: ""), for: .normal)
		confirmAppointmentButton <~ Style.RoundedButton.redBackground
        confirmAppointmentButton.addTarget(self, action: #selector(confirmAppointmentTap(_:)), for: .touchUpInside)
        actionButtonsStackView.addArrangedSubview(confirmAppointmentButton)
		
		confirmAppointmentButton.height(48)
    }
	
    private func embedActionButton(_ button: UIButton, to stackView: UIStackView) {
        let buttonContainerView = UIView()
        buttonContainerView.backgroundColor = .clear
                
        buttonContainerView.addSubview(button)
        
        button.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate(
            [
                button.topAnchor.constraint(
                    equalTo: buttonContainerView.topAnchor,
                    constant: 5
                ),
                button.bottomAnchor.constraint(
                    equalTo: buttonContainerView.bottomAnchor,
                    constant: -5
                ),
                button.trailingAnchor.constraint(
                    equalTo: buttonContainerView.trailingAnchor,
                    constant: -16
                ),
                button.leadingAnchor.constraint(
                    equalTo: buttonContainerView.leadingAnchor,
                    constant: 16
                ),
                button.heightAnchor.constraint(equalToConstant: 42)
            ]
        )
        
        stackView.addArrangedSubview(buttonContainerView)
    }
    
    private func addCancelAppointmentButton(to stackView: UIStackView) {
        let cancelAppointmentButton = RoundEdgeButton()
		cancelAppointmentButton.setTitle(NSLocalizedString("clinic_cancel", comment: ""), for: .normal)
		cancelAppointmentButton <~ Style.RoundedButton.whiteGrayBackground
		
        cancelAppointmentButton.addTarget(self, action: #selector(cancelAppointmentTap(_:)), for: .touchUpInside)
        embedActionButton(cancelAppointmentButton, to: stackView)
		
		cancelAppointmentButton.height(48)
    }

    private func addChangeAppointmentButton(to stackView: UIStackView) {
        guard let kind = self.appointmentOperationKind
        else { return }
        
        var buttonTitle = ""
        
        switch kind {
            case .futureOnlineAppointment:
                buttonTitle = "clinic_change"
            case .avisOfflineFutureAppointment:
                buttonTitle = "clinic_new_offline_appointment"
            default:
                return
        }
                
        let createNewAppointmentButton = RoundEdgeButton()
		createNewAppointmentButton.setTitle(NSLocalizedString(buttonTitle, comment: ""), for: .normal)
		createNewAppointmentButton <~ Style.RoundedButton.redBackground
        
        createNewAppointmentButton.addTarget(
            self,
            action: #selector(changeAppointmentTap(_:)),
            for: .touchUpInside
        )
        
        embedActionButton(createNewAppointmentButton, to: stackView)
		
		createNewAppointmentButton.height(48)
    }
    
    // MARK: - Actions:

    @objc func confirmAppointmentTap(_ sender: UIButton) {
        guard let kind = appointmentOperationKind
        else { return }
                
        output.confirmAppointment(kind, kind.update)
    }

    @objc func cancelAppointmentTap(_ sender: UIButton) {
        handleActionWithAlert(
            sender,
            questionText: "clinic_appointment_cancel_alert",
            yesAction: { [weak self] in
                guard let self = self,
                      let kind = self.appointmentOperationKind
                else { return }
                self.output.cancelAppointment(kind)
            },
            noAction: {}
        )
    }

    @objc func changeAppointmentTap(_ sender: UIButton) {
        guard let kind = self.appointmentOperationKind
        else { return }
        
        switch kind {
            case .futureOnlineAppointment:
                self.output.changeAppointment(kind)
            case .avisOfflineFutureAppointment(let avisAppointment, let optional, _):
                handleActionWithAlert(
                    sender,
                    questionText: "clinic_appointment_reschedule_alert",
                    yesAction: { [weak self] in
                        guard let self = self,
                              let kind = self.appointmentOperationKind
                        else { return }
                        self.output.changeAppointment(kind)
                    },
                    noAction: { [weak self] in
                        guard let self = self
                        else { return }
                        /// "no" button action means that we will not modify current appointment
                        /// but create new one
                        self.output.changeAppointment(
                            .avisOfflineFutureAppointment(
                                avisAppointment,
                                optional,
                                create: true
                            )
                        )
                    }
                )
            case .confirmOnlineAppointment, .pastOnlineAppointment, .avisOfflinePastAppointment:
                return
        }
    }
    
    private func handleActionWithAlert(
        _ sender: UIButton,
        questionText: String,
        yesAction: @escaping () -> Void,
        noAction: @escaping () -> Void
    ) {
        let alert = UIAlertController(
            title: NSLocalizedString(questionText, comment: ""),
            message: nil,
            preferredStyle: .alert
        )
        
        let noAction = UIAlertAction(
            title: NSLocalizedString("common_no_button", comment: ""),
            style: .cancel
        ) { _ in
            noAction()
        }
        alert.addAction(noAction)
        
        let yesAction = UIAlertAction(
            title: NSLocalizedString("common_yes_button", comment: ""),
            style: .default
        ) { _ in
            yesAction()
        }
        alert.addAction(yesAction)

        present(alert, animated: true)
    }
	
	struct Constants {
		static let cardInsetsWithShadow = UIEdgeInsets(top: 6, left: 16, bottom: 6, right: 16)
		static let cardInsetsWithoutShadow = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
	}
}
