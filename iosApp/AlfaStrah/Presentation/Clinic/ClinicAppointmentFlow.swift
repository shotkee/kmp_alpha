//
//  ClinicAppointmentFlow.swift
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 05/07/2018.
//  Copyright © 2018 RedMadRobot. All rights reserved.
//

import UIKit
import Legacy
import CoreLocation

// swiftlint:disable file_length

class ClinicAppointmentFlow: BaseFlow,
							 ClinicsServiceDependency,
							 InsurancesServiceDependency,
							 GeolocationServiceDependency,
							 CalendarServiceDependency,
							 AccountServiceDependency {
    var clinicsService: ClinicsService!
    var geoLocationService: GeoLocationService!
    var calendarService: CalendarService!
    var applicationFlow: ApplicationFlow = ApplicationFlow.shared
    var accountService: AccountService!
    var insurancesService: InsurancesService!
    var onlineClinicAppointmentFlow: CommonClinicAppointmentFlow?
    
    private let clinicsStoryboard = UIStoryboard(name: "Clinics", bundle: nil)
    private var insurance: Insurance!
    private var userInputSpecialityText: String?
    
    private var notifyChanges: [() -> Void] = []
    private lazy var coordinateHandler: CoordinateHandler = {
        let handler = CoordinateHandler()
        container?.resolve(handler)
        return handler
    }()

    private enum ClinicAppointmentError: Error {
        case unknown
    }

    /// Notifies about order updates.
    private func notifyUpdate() {
        notifyChanges.forEach { $0() }
    }

    // MARK: - Clinics Picker

    /// Start flow to create offline doctor appointment for insurance
    func start(
        insuranceId: String,
        mode: ViewControllerShowMode
    ) {
        insurancesService.insurance(useCache: true, id: insuranceId) { result in
            switch result {
                case .success(let insurance):
                    self.insurance = insurance
                    self.showClinics(with: insurance, mode: mode)
                case .failure(let error):
                    self.show(error: error)
            }
        }
    }
    
    /// interactive support handling
    func start(
        insuranceId: String,
        mode: ViewControllerShowMode,
        showLoading: Bool
    ) {
        var hide: ((_ completion: (() -> Void)?) -> Void)?
        
        if showLoading {
            hide = fromViewController.showLoadingIndicator(message: NSLocalizedString("common_load", comment: ""))
        }
        
        insurancesService.insurance(useCache: true, id: insuranceId) { result in
            if showLoading {
                hide?(nil)
            }
            
            switch result {
                case .success(let insurance):
                    self.insurance = insurance
                    self.showClinics(with: insurance, mode: mode)
                case .failure(let error):
                    self.show(error: error)
            }
        }
    }

    /// Start flow to create offline doctor appointment for insurance
    func start(insurance: Insurance, selectedFilterName: String? = nil, mode: ViewControllerShowMode) {
        showClinics(with: insurance, selectedFilterName: selectedFilterName, mode: mode)
    }

    /// Start flow and show clinic info view controller
	func start(clinicKind: ClinicKind, insurance: Insurance, navigationSource: AnalyticsParam.NavigationSource) {
        logger?.debug("")
        
        self.insurance = insurance
        self.clinicKind = clinicKind
		
		setupLocationServices()

        switch clinicKind {
            case .info:
				self.showClinic(navigationSource: navigationSource)
            case .appointment:
                self.showClinic(showConfirmButton: false, navigationSource: navigationSource)
        }
    }

    /// Start flow and show doctor appointment info screen
    func start(appointmentId id: String, insurance: Insurance, mode: ViewControllerShowMode) {
        self.insurance = insurance
        appointmentInfo(.appointmentId(id), mode: mode)
    }
    
    /// Start flow for avis offline appoinment update
    func start(
        from flow: CommonClinicAppointmentFlow? = nil,
        with insurance: Insurance,
        avisAppointment: AVISAppointment,
        settings: OfflineAppointmentSettings,
        create: Bool
    ) {
        guard let clinic = avisAppointment.clinic
        else { return }
        
        self.insurance = insurance
        
        let avisId = create ? nil : avisAppointment.id
        
        showCreateOfflineAppointment(
            from: flow,
            outdatedAvisId: avisId,
            clinic: clinic,
            settings: settings
        )
    }

    private func showClinics(with insurance: Insurance, selectedFilterName: String? = nil, mode: ViewControllerShowMode) {
        self.insurance = insurance
		
		let viewController = clinicPicker(mode: mode)
		
		viewController.hidesBottomBarWhenPushed = true
		
        createAndShowNavigationController(viewController: viewController, mode: mode)
        setupLocationServices()
		loadInitialDataWithSelectedFilterName(selectedFilterName)
    }
	
	func showClinicsWithFilterId(_ selectedFilterId: String? = nil, for insurance: Insurance, mode: ViewControllerShowMode) {
		self.insurance = insurance
		
		let viewController = clinicPicker(mode: mode)
		
		viewController.hidesBottomBarWhenPushed = true
		
		createAndShowNavigationController(viewController: viewController, mode: mode)
		setupLocationServices()
		loadInitialDataWithSelectedFilterId(selectedFilterId)
	}

	private func loadInitialData(completion: @escaping (Result<Void, Error>) -> Void) {
        let group = DispatchGroup()
        var downloadError: Error?

        group.enter()
        clinicsService.citiesWithMetro { [weak self] result in
            guard let self = self else { return }

            switch result {
                case .success(let cities):
                    self.cities = cities
                case .failure(let error):
                    self.show(error: error)
                    downloadError = error
            }
            group.leave()
        }

        group.enter()
        clinicsService.clinicsTreatments { [weak self] result in
            guard let `self` = self else { return }

            switch result {
                case .success(let treatments):
                    self.treatmentFilters = treatments
                        .map {
                            ClinicsTreatmentPickerViewController.TreatmentFilter(
                                isActive: false,
                                treatment: $0
                            )
                        }
                case .failure(let error):
                    self.show(error: error)
                    downloadError = error
            }
            group.leave()
        }

        group.notify(queue: .main) {
            if let error = downloadError {
				completion(.failure(error))
            } else {
				completion(.success(()))
            }
        }
    }
	
	private func loadInitialDataWithSelectedFilterName(_ selectedFilterName: String? = nil) {
		loadInitialData { result in
			switch result {
				case .success:
					self.selectedCity = nil
					self.setSelectFilterByFilterName(selectedFilterName)
				case .failure(let error):
					self.clinicsData = .error(error)
					self.notifyUpdate()
			}
		}
	}
	
	private func loadInitialDataWithSelectedFilterId(_ selectedFilterId: String? = nil) {
		loadInitialData { result in
			switch result {
				case .success:
					self.selectedCity = nil
					self.setSelectFilterByFilterId(selectedFilterId)
					
				case .failure(let error):
					self.clinicsData = .error(error)
					self.notifyUpdate()
					
			}
		}
	}
	
    private func setSelectFilterByFilterName(_ filterName: String?) {
        if let filterName = filterName,
           !filterName.isEmpty,
           let index = self.treatmentFilters.firstIndex(
            where: { $0.treatment.title.caseInsensitiveCompare(filterName) == .orderedSame }
           ) {
            self.treatmentFilters[index].isActive = true
            self.hasActiveTreatmentFilters = true
        }
    }
	
	private func setSelectFilterByFilterId(_ filterId: String?) {
		if let filterId,
			!filterId.isEmpty,
		   let index = self.treatmentFilters.firstIndex(where: {
			   $0.treatment.id == filterId
		   }) {
			self.treatmentFilters[index].isActive = true
			self.hasActiveTreatmentFilters = true
		}
	}
	
	private var clinicPickerViewController: ClinicPickerViewController?

    private func clinicPicker(mode: ViewControllerShowMode) -> ClinicPickerViewController {
        let viewController: ClinicPickerViewController = clinicsStoryboard.instantiate()
		self.clinicPickerViewController = viewController
        let metroViewController = metroStationsViewController()
        let clinicsViewController = clinicsListViewController(showMetroDistance: false)
        container?.resolve(clinicsViewController)
		
		let mapViewController = clinicsMapViewController(
			presentInfoDemoSheet: { [weak viewController] in
				guard let viewController
				else { return }
				
				DemoBottomSheet.presentInfoDemoSheet(from: viewController)
			}
		)
		
        viewController.input = ClinicPickerViewController.Input(
            selectedCity: {
                self.selectedCity
            },
            hasActiveFilters: {
                self.hasActiveTreatmentFilters || self.hasActiveServiceHoursFilters || self.hasActiveFranchiseFilters
            },
            clinicsListPickerView: clinicsViewController.view,
			mapPickerView: mapViewController.view
        )
        viewController.output = ClinicPickerViewController.Output(
            selectCity: selectCity,
            selectTreatmentFilters: selectFilters,
            resetTreatmentFilters: resetFilters
        )
        if mode == .modal {
            viewController.addCloseButton { [weak viewController] in
                viewController?.dismiss(animated: true, completion: nil)
            }
        }
        self.clinicsViewController = clinicsViewController
        self.metroViewController = metroViewController
        self.mapViewController = mapViewController
        notifyChanges.append(viewController.notify.changed)
        return viewController
    }

    // MARK: - Error handle

    private func show(error: Error) {
        ErrorHelper.show(error: error, alertPresenter: alertPresenter)
    }

    // MARK: - GeoLocation

    private var geoLocationAvailabilitySubscription: Subscription?
    private var geoLocationSubscription: Subscription?
    private var currentPosition: Coordinate?

    /// Sets up GeoLocationService subscriptions.
    private func setupLocationServices() {
        geoLocationService.requestAvailability(always: false)

        geoLocationAvailabilitySubscription = geoLocationService.subscribeForAvailability { [weak self] availability in
            guard let `self` = self else { return }

            switch availability {
                case .allowedAlways, .allowedWhenInUse:
                    break
                case .denied, .notDetermined:
                    if let rootController = self.navigationController {
                        let controller = UIHelper.findTopModal(controller: rootController)
                        UIHelper.showLocationRequiredAlert(from: controller, locationServicesEnabled: true)
                    }
                case .restricted:
                    if let rootController = self.navigationController {
                        let controller = UIHelper.findTopModal(controller: rootController)
                        UIHelper.showLocationRequiredAlert(from: controller, locationServicesEnabled: false)
                    }
            }
        }

        geoLocationSubscription = geoLocationService.subscribeForLocation { [weak self] deviceLocation in
            guard let self
			else { return }

            self.currentPosition = deviceLocation
            self.selectedCity = nil
            self.geoLocationSubscription?.unsubscribe()
        }
    }

    // MARK: - Clinics list

    private let supportPhone = Phone(plain: "+78007000998", humanReadable: "8 800 700 09 98")
    private var clinicsData: NetworkData<ClinicResponse> = .loading
    private var clinicsViewController: ClinicsListViewController?

    private func clinicsListViewController(showMetroDistance: Bool) -> ClinicsListViewController {
        let viewController: ClinicsListViewController = clinicsStoryboard.instantiate()
        viewController.input = ClinicsListViewController.Input(
            showMetroDistance: showMetroDistance,
            data: { [weak self] in
                guard let `self` = self else { return .error(ClinicAppointmentError.unknown) }

				return self.clinicsData
            },
            supportPhone: supportPhone
        )
        viewController.output = ClinicsListViewController.Output(
            clinic: { [weak self] clinic in
                guard let self
				else { return }

                self.clinicKind = .appointment(clinic)
				self.confirmAppointment(
					viewController: viewController,
					clinic: clinic
				)
            },
            refresh: { [weak self] in
                guard let `self` = self else { return }

                self.loadClinics(in: self.selectedCity)
            },
            callSupport: { [weak self] in
                guard let `self` = self else { return }

                self.phoneTap(self.supportPhone)
            },
			tapWebSiteCallback:
			{ 
				[weak viewController] url in
				
				guard let viewController = self.navigationController?.topViewController,
					  let url
				else { return }
				
				WebViewer.openDocument(
					url,
					from: viewController
				)
			},
			tapCallCallback:
			{
				[weak viewController] phoneList in
				
				guard let viewController
				else { return }
				
				
				self.showCallNumberActionSheet(
					phoneList: phoneList,
					viewController: viewController
				)
			},
			tapCell:
			{
				[weak viewController] clinic in
				
				self.clinicKind = .appointment(clinic)
				self.showClinic(navigationSource: .appointmentInfo)
			}
        )
		
        notifyChanges.append(viewController.notify.changed)
        return viewController
    }
	
	private func showCallNumberActionSheet(
		phoneList: [Phone],
		viewController: ViewController
	) {
		let actionSheet = UIAlertController(
			title: nil,
			message: nil,
			preferredStyle: .actionSheet
		)
		
		phoneList.forEach 
		{
			phone in
			
			let callNumberAction = UIAlertAction(
				title: phone.humanReadable,
				style: .default
			) { [weak self] _ in
				
				guard let url = URL(string: "telprompt://" + phone.plain)
				else { return }

				UIApplication.shared.open(url, completionHandler: nil)
			}
			
			actionSheet.addAction(callNumberAction)
		}
		
		let cancel = UIAlertAction(
			title: NSLocalizedString(
				"common_cancel_button",
				comment: ""
			),
			style: .cancel,
			handler: nil
		)
		actionSheet.addAction(cancel)
		
		viewController.present(
			actionSheet,
			animated: true
		)
	}

    private var clinics: [Clinic] = []
	private var cityList: [ClinicWithMetro] = []
	private var filters: [ClinicFilter] = []

    /// Loads clinics in the selected city
    private func loadClinics(in city: CityWithMetro?) {
        if let city = city {
            loadMetroStations(in: city)
        } else {
            loadAllClinics()
        }
		
        if !clinicsData.isLoading {
            clinicsData = .loading
            metroStations = []
            notifyUpdate()
        }
    }

    /// Loads all clinics (dot not send filters to backend. We do filter local)
    private func loadAllClinics() {
        clinicsService.clinics(insuranceId: insurance.id) { [weak self] result in
            guard let `self` = self else { return }

            switch result {
                case .success(let clinicsResponse):
					self.clinicPickerViewController?.notify.updateVisibleRightBarButton(true)
					self.clinics = clinicsResponse.clinicList
					self.cityList = clinicsResponse.cityList
					self.filters = clinicsResponse.filterList
                    self.clinicsData = .data(clinicsResponse)
                case .failure(let error):
                    self.show(error: error)
                    self.clinicsData = .error(error)
            }
            self.notifyUpdate()
        }
    }
    
    // MARK: - Map

    private var mapViewController: ClinicsMapViewController?

    private func clinicsMapViewController(
		presentInfoDemoSheet: @escaping () -> Void
	) -> ClinicsMapViewController {
        let viewController: ClinicsMapViewController = clinicsStoryboard.instantiate()
		container?.resolve(viewController)
        viewController.input = ClinicsMapViewController.Input(
            userLocation: { [weak self] in
                self?.currentPosition
            },
            cityLocation: { [weak self] in
                self?.selectedCity?.coordinate
            },
            defaultLocation: geoLocationService.defaultLocation,
            data: { [weak self] in
                guard let `self` = self else { return .error(ClinicAppointmentError.unknown) }

                return self.clinicsData
            }
        )
        // swiftlint:disable:next trailing_closure
        viewController.output = ClinicsMapViewController.Output(
            clinic: { [weak self] clinic in
                guard let `self` = self else { return }

                self.clinicKind = .appointment(clinic)
				self.showClinic(navigationSource: .clinics)
            },
            confirmAppointment: { [weak self, weak viewController] clinic in
                guard let self,
                      let viewController
                else { return }
				
				if accountService.isDemo
				{
					presentInfoDemoSheet()
				}
				else
				{
					self.clinicKind = .appointment(clinic)
					self.confirmAppointment(
						viewController: viewController,
						clinic: clinic
					)
				}
            }
        )
        notifyChanges.append(viewController.notify.changed)
        return viewController
    }

    // MARK: - Metro stations

    private var metroStations: [MetroStation] = []
    private var metroViewController: ClinicsMetroStationsViewController?

    private func metroStationsViewController() -> ClinicsMetroStationsViewController {
        let viewController: ClinicsMetroStationsViewController = clinicsStoryboard.instantiate()
        // swiftlint:disable:next trailing_closure
        viewController.input = ClinicsMetroStationsViewController.Input(
            metroStations: { [weak self] in
                guard let `self` = self else { return [] }

                var filteredMetroStations: [MetroStation] = []
                for metroStation in self.metroStations {
                    var filteredMetroStation = metroStation
                    filteredMetroStations.append(filteredMetroStation)
                }
                return filteredMetroStations
            }
        )
        // swiftlint:disable:next trailing_closure
        viewController.output = ClinicsMetroStationsViewController.Output(
            station: { [weak self] metroStation in
                guard let `self` = self, metroStation.clinicCount != nil else { return }

                let clinicsListViewController = self.clinicsListViewController(showMetroDistance: true)
                self.createAndShowNavigationController(viewController: clinicsListViewController, mode: .push)
            }
        )

        notifyChanges.append(viewController.notify.changed)
        return viewController
    }

    /// Loads metro stations and all clinics in selected city
    private func loadMetroStations(in city: CityWithMetro) {
        clinicsService.metroStations(in: city, insuranceId: insurance.id) { [weak self] result in
            guard let self = self else { return }

            switch result {
                case .success(let metroStations):
                    self.metroStations = metroStations
                    var ids: Set<String> = []
                    self.clinics = clinics.filter { ids.insert($0.id).inserted }
                case .failure(let error):
                    self.show(error: error)
                    self.clinicsData = .error(error)
            }
            self.notifyUpdate()
        }
    }

    // MARK: - Cities

    private var cities: [CityWithMetro] = []
    /// Closest available city determined by geo service
    private var closestCity: CityWithMetro?
    /// Currently selected city for the flow
    private var selectedCity: CityWithMetro? {
        didSet {
            loadClinics(in: selectedCity)
            notifyUpdate()
        }
    }

    private func selectCity() {
        let viewController: ClinicsCitiesListViewController = clinicsStoryboard.instantiate()
        viewController.input = ClinicsCitiesListViewController.Input(cities: self.cities)
        // swiftlint:disable:next trailing_closure
        viewController.output = ClinicsCitiesListViewController.Output(
            selectedCity: { city in
                self.selectedCity = city ?? self.closestCity
                self.navigationController?.popViewController(animated: true)
            }
        )
        createAndShowNavigationController(viewController: viewController, mode: .push)
    }

    // MARK: - Treatment filters

    private var treatmentFilters: [ClinicsTreatmentPickerViewController.TreatmentFilter] = []
    private var hasActiveTreatmentFilters: Bool = false
    private var serviceHoursFilters: [ClinicsTreatmentPickerViewController.ServiceHoursFilter] = []
    private var hasActiveServiceHoursFilters: Bool = false
    private var franchiseFilters = ClinicsTreatmentPickerViewController.FranchiseAvailability.allCases
                .map { ClinicsTreatmentPickerViewController.FranchiseFilter(type: $0, isActive: false) }
    private var hasActiveFranchiseFilters: Bool = false
	
	private weak var clinicFiltersViewController: ClinicFiltersViewController?
	private var cacheClinicFilter: SelectClinicFilter = .init()
	private var selectClinicFilter: SelectClinicFilter = .init()

    private func selectFilters() {
        let viewController = ClinicFiltersViewController()
        container?.resolve(viewController)
		
		self.selectClinicFilter = self.cacheClinicFilter
		clinicFiltersViewController = viewController
		
		viewController.input = .init(
			cacheClinicFilter: cacheClinicFilter,
			cityList: self.cityList,
			filterList: self.filters
		)
		
		viewController.addBackButton 
		{
			self.selectClinicFilter = .init()
			self.navigationController?.popViewController(animated: true)
		}
		
		viewController.output = .init(
			onMetroTap: 
			{
				cityList in
				
				if let selectCityId = self.selectClinicFilter.selectCityId,
				   let selectCityName = self.selectClinicFilter.selectCityName,
				   let clinicMetro = self.cityList.first(where: { $0.id == selectCityId})
				{
					self.showClinicMetroStationsFilterViewController(
						typeData: .citiesList(self.cityList),
						cacheData: .cityList(
							self.selectClinicFilter.selectCityId,
							self.selectClinicFilter.selectCityName
						),
						clinicMetro: clinicMetro
					)
				}
				else
				{
					self.showClinicTownOrSpecialtyFilterViewController(
						typeData: .citiesList(cityList),
						cacheData: .cityList(
							self.selectClinicFilter.selectCityId,
							self.selectClinicFilter.selectCityName
						),
						cityId: self.selectClinicFilter.selectCityId
					)
				}
			},
			onSpecialityTap: 
			{
				specialties in
				
				self.showClinicTownOrSpecialtyFilterViewController(
					typeData: .specialty(specialties),
					cacheData: .specialty(
						self.selectClinicFilter.selectedFilters["специальности"] ?? []
					)
				)
			},
			onInformationTap: 
			{
				[weak viewController] title, clinicFilterInformations in
				
				guard let viewController
				else { return }
				
				self.showClinicScreenModalViewController(
					viewController: viewController,
					title: title,
					clinicFilterInformations: clinicFilterInformations
				)
			}, 
			onResetFilter:
			{
				self.selectClinicFilter.selectCityId = nil
				self.selectClinicFilter.selectCityName = nil
				self.selectClinicFilter.selectMetroStations = []
				self.selectClinicFilter.selectedFilters = [:]
			},
			onApplyFilter:
			{
				filter in
					
				self.updateSelectClinicFilter(selectClinicFilter: filter)
				self.navigationController?.popViewController(animated: true)
				self.clinicsViewController?.notify.filtered(filter)
				self.mapViewController?.notify.updateFilter(filter)
				self.clinicPickerViewController?.notify.updateFilter(filter)
			}
		)
		
		createAndShowNavigationController(
			viewController: viewController,
			mode: .push
		)
    }
	
	static func getClinicsWithFilter(
		selectClinicFilter: SelectClinicFilter,
		clinics: [Clinic],
		filters: [ClinicFilter]
	) -> [Clinic]
	{
		if selectClinicFilter.isEmpty
		{
			return clinics
		}
		else
		{
			var filterClinics: [Clinic] = []
			var anotherFilters: [[Clinic]] = []
			
			if !selectClinicFilter.selectMetroStations.isEmpty
			{
				filterClinics = filterMetroStation(
					clinics: clinics,
					metroStations: selectClinicFilter.selectMetroStations
				)
			}
			else
			{
				filterClinics = clinics
			}
			
			filters.forEach
			{
				filter in
				
				if let value = selectClinicFilter.selectedFilters[filter.title.lowercased()],
				   !value.isEmpty
				{
					anotherFilters.append(
						getClinicFilterValues(
							clinics: clinics,
							titleFilter: filter.title,
							selectedFilterValues: value
						)
					)
				}
			}
			
			let isEmptyAnotherFilters = anotherFilters
				.filter({ $0.isEmpty }).isEmpty
			
			let isEmptyAllFilters = filterClinics.isEmpty && isEmptyAnotherFilters
			
			guard !isEmptyAllFilters
			else { return [] }
			
			anotherFilters.forEach({ filterArray in
				filterClinics = getUpdateClinics(
					firstClinicsArray: filterClinics,
					secondClinicsArray: filterArray
				)
			})
			
			return filterClinics
		}
	}
	
	private static func getUpdateClinics(
		firstClinicsArray: [Clinic],
		secondClinicsArray: [Clinic]
	) -> [Clinic]
	{
		if !firstClinicsArray.isEmpty,
		   secondClinicsArray.isEmpty
		{
			return firstClinicsArray
		}
		
		var updatedClinics: [Clinic] = []
		
		firstClinicsArray.forEach
		{
			clinic in
			
			if secondClinicsArray.contains(where: { $0.id == clinic.id }),
			   !updatedClinics.contains(where: { $0.id == clinic.id })
			{
				updatedClinics.append(clinic)
			}
		}
	
		return updatedClinics
	}
	
	private static  func filterMetroStation(
		clinics: [Clinic],
		metroStations: [MetroStation]
	) -> [Clinic]
	{
		var filtredClinics: [Clinic] = []
		
		clinics.forEach
		{
			clinic in
			
			(clinic.metroList ?? []).forEach
			{
				metroStation in
				
				if metroStations.contains(where: { $0.id == metroStation.id }),
				   !filtredClinics.contains(where: { $0.id == clinic.id })
				{
					filtredClinics.append(clinic)
				}
			}
		}
		
		return filtredClinics
	}
	
	private static  func getClinicFilterValues(
		clinics: [Clinic],
		titleFilter: String,
		selectedFilterValues: [String]
	) -> [Clinic]
	{
		var filtredClinics: [Clinic] = []
		
		clinics.forEach
		{
			clinic in
			
			if let filterSpecialties = (clinic.filterList ?? []).first(where: { $0.title.lowercased() == titleFilter.lowercased() })
			{
				filterSpecialties.values.forEach
				{
					specialty in
					
					if selectedFilterValues.contains(where: { $0.lowercased() == specialty.lowercased()}),
					   !filtredClinics.contains(where: { $0.id == clinic.id })
					{
						filtredClinics.append(clinic)
					}
				}
			}
		}
		
		return filtredClinics
	}
	
	private func updateSelectClinicFilter(selectClinicFilter: SelectClinicFilter?)
	{
		self.cacheClinicFilter = selectClinicFilter ?? cacheClinicFilter
	}
	
	private func resetSelectClinicFilter(selectClinicFilter: SelectClinicFilter?)
	{
		self.cacheClinicFilter = selectClinicFilter ?? .init()
	}
	
	private func updateCityAndMetroFilter(
		selectCityId: Int?,
		selectCityName: String?,
		selectMetroStations: [MetroStation]
	)
	{
		selectClinicFilter.selectCityId = selectCityId
		selectClinicFilter.selectCityName = selectCityName
		selectClinicFilter.selectMetroStations = selectMetroStations
		clinicFiltersViewController?.notify.updateCityAndMetroFilter(
			selectCityId,
			selectCityName,
			selectMetroStations
		)
	}
	
	private func updateSpecialties(specialties: [String])
	{
		selectClinicFilter.selectedFilters["специальности"] = specialties
		clinicFiltersViewController?.notify.updateSpecialties(specialties)
	}
	
	private func showClinicScreenModalViewController(
		viewController: ClinicFiltersViewController,
		title: String,
		clinicFilterInformations: [ClinicFilterInformation]
	)
	{
		let clinicScreenModalViewController = ClinicScreenModalViewController()
		container?.resolve(clinicScreenModalViewController)
		
		clinicScreenModalViewController.input = .init(
			title: title,
			clinicFilterInformations: clinicFilterInformations
		)
		
		clinicScreenModalViewController.output = .init(
			close:
			{
				[weak clinicScreenModalViewController] in
				
				clinicScreenModalViewController?.dismiss(animated: true)
			}
		)
		
		viewController.showBottomSheet(
			contentViewController: clinicScreenModalViewController,
			backgroundColor: .Background.backgroundSecondary
		)
	}
	
	private func showClinicTownOrSpecialtyFilterViewController(
		typeData: ClinicTownOrSpecialtyFilterViewController.TypeData,
		cacheData: ClinicTownOrSpecialtyFilterViewController.CacheData,
		cityId: Int? = nil,
		onDismiss: ((ClinicWithMetro) -> Void)? = nil
	)
	{
		let viewController = ClinicTownOrSpecialtyFilterViewController()
		container?.resolve(viewController)
		
		viewController.input = .init(
			cacheData: cacheData,
			typeData: typeData,
			cityId: cityId
		)
		
		viewController.output = .init(
			goToChat:
		 {
			 [weak viewController] in
			 
			 guard let viewController
			 else { return }
			 
			 let chatFlow = ChatFlow()
			 self.container?.resolve(chatFlow)
			 
			 chatFlow.show(from: viewController, mode: .fullscreen)
		 },
			apply:
		{
			selectedData in
					
			switch selectedData
			{
				case .cityWithMetro(let clinicMetro):
					if let onDismiss = onDismiss
					{
						onDismiss(clinicMetro)
						self.navigationController?.popViewController(animated: true)
					}
					else
					{
						self.showClinicMetroStationsFilterViewController(
							typeData: typeData,
							cacheData: cacheData,
							clinicMetro: clinicMetro
						)
					}
				
				case .specialty(let specialties):
					self.updateSpecialties(specialties: specialties)
					self.navigationController?.popViewController(animated: true)
				}
			}
		)
		
		createAndShowNavigationController(
			viewController: viewController,
			mode: .push
		)
	}
	
	private func showClinicMetroStationsFilterViewController(
		
		typeData: ClinicTownOrSpecialtyFilterViewController.TypeData,
		cacheData: ClinicTownOrSpecialtyFilterViewController.CacheData,
		clinicMetro: ClinicWithMetro
	)
	{
		let viewController = ClinicMetroStationsFilterViewController()
		container?.resolve(viewController)
		
		viewController.input = .init(
			cacheCityId: self.selectClinicFilter.selectCityId,
			cacheMetroStation: self.selectClinicFilter.selectMetroStations,
			clinicMetro: clinicMetro
		)
		
		viewController.output = .init(
			updateCity:
		 {
			 cityId in
			 
			 self.showClinicTownOrSpecialtyFilterViewController(
				typeData: typeData,
				cacheData: cacheData,
				cityId: cityId,
				onDismiss:
				{
					[weak viewController] clinicMetro in
					
					viewController?.notify.update(clinicMetro)
				}
			 )
		 },
			apply:
		 { 
			 [weak viewController] cityWithMetroStationTuple in
			 
			 guard let viewController
			 else { return }
			 
			 if let selectCityId = self.selectClinicFilter.selectCityId,
				let cityId = cityWithMetroStationTuple.cityId,
				let cityName = cityWithMetroStationTuple.cityName,
				selectCityId != cityWithMetroStationTuple.cityId
			 {
				 self.showResetCityAndMetroStationFilterAlert(
					cityWithMetroStationTuple: (cityId: cityId, cityName: cityName, metroStation: cityWithMetroStationTuple.metroStation),
					viewController: viewController
				 )
			 }
			 else
			 {
				 self.updateCityAndMetroFilter(
					selectCityId: cityWithMetroStationTuple.cityId,
					selectCityName: cityWithMetroStationTuple.cityName,
					selectMetroStations: cityWithMetroStationTuple.metroStation
				 )
				 
				 self.navigationController?.popViewController(animated: false)
				 
				 if let _ = self.navigationController?.topViewController as? ClinicFiltersViewController
				 {
					 return
				 }
				 else
				 {
					 self.navigationController?.popViewController(animated: false)
				 }
			 }
		 }
		)
		
		createAndShowNavigationController(
			viewController: viewController,
			mode: .push
		)
	}
	
	private func showResetCityAndMetroStationFilterAlert(
		cityWithMetroStationTuple: (cityId: Int, cityName: String, metroStation: [MetroStation]),
		viewController: ViewController
	)
	{
		let actionSheet = UIAlertController(
			title: NSLocalizedString("clinic_filter_reset_filter_title_alert", comment: ""),
			message: NSLocalizedString("clinic_filter_reset_filter_description_alert", comment: ""),
			preferredStyle: .alert
		)
		
		let resetAction = UIAlertAction(
			title: NSLocalizedString("common_reset_action", comment: ""),
			style: .cancel
		) { _ in
			
			self.updateCityAndMetroFilter(
				selectCityId: cityWithMetroStationTuple.cityId,
				selectCityName: cityWithMetroStationTuple.cityName,
				selectMetroStations: cityWithMetroStationTuple.metroStation
			)
			self.navigationController?.popViewController(animated: false)
		}
		
		let leaveAction = UIAlertAction(
			title: NSLocalizedString(
				"clinic_filter_reset_filter_leave_button_title",
				comment: ""
			),
			style: .default,
			handler: nil
		)
		
		actionSheet.addAction(leaveAction)
		actionSheet.addAction(resetAction)
		
		viewController.present(
			actionSheet,
			animated: true
		)
	}

    private func filter(clinics: [Clinic]) -> [Clinic] {
        var filteredClinics: [Clinic] = clinics
        
        if hasActiveFranchiseFilters {
            let activeFilters = franchiseFilters
                .filter { $0.isActive }
                .map { $0.type }

            if !activeFilters.isEmpty
                && activeFilters.count < franchiseFilters.count
            {
				filteredClinics = []
            }
        }

        return filteredClinics
    }

    private func resetFilters() {
        treatmentFilters = treatmentFilters.map { filter in
            var filter = filter
            filter.isActive = false
            return filter
        }
        serviceHoursFilters = serviceHoursFilters.map { filter in
            var filter = filter
            filter.isActive = false
            return filter
        }
        franchiseFilters = franchiseFilters.map { filter in
            var filter = filter
            filter.isActive = false
            return filter
        }
        hasActiveTreatmentFilters = false
        hasActiveServiceHoursFilters = false
        hasActiveFranchiseFilters = false
        notifyUpdate()
    }

    // MARK: - Clinic

    enum ClinicKind {
        case info(Clinic)
        case appointment(Clinic)

        var clinic: Clinic {
            switch self {
                case .info(let clinic):
                    return clinic
                case .appointment(let clinic):
                    return clinic
            }
        }
    }

    private var clinicKind: ClinicKind?

	private func showClinic(showConfirmButton: Bool = true, navigationSource: AnalyticsParam.NavigationSource) {
        let kind: ClinicViewController.Kind
        let selectedClinic: Clinic

        switch clinicKind {
            case .info(let clinic)?:
                selectedClinic = clinic
                kind = .clinicInfo(selectedClinic, fullInfo: insurance.accessClinicPhone ?? false)
            case .appointment(let clinic)?:
                selectedClinic = clinic
                kind = .createAppointment(
                    selectedClinic,
                    fullInfo: insurance.accessClinicPhone ?? false
                )
            case .none:
                return
        }

		let clinicType = selectedClinic.buttonAction == .appointmentOnline ? "online" : "offline"
        analytics.track(
            event: AnalyticsEvent.Clinic.openClinic,
            properties: [
                AnalyticsParam.Clinic.clinicType: clinicType,
                AnalyticsParam.Clinic.clinicName: selectedClinic.title
            ]
        )

        let viewController: ClinicViewController = clinicsStoryboard.instantiate()
        container?.resolve(viewController)
        viewController.input = ClinicViewController.Input(
            kind: kind,
            showConfirmButton: showConfirmButton
        )
        viewController.output = ClinicViewController.Output(
            confirmAppointment: { [weak self, weak viewController] in
                guard let self = self,
                      let viewController = viewController,
                      let clinic = self.clinicKind?.clinic
                else { return }
                
				if let analyticsData = analyticsData(
						from: self.insurancesService.cachedShortInsurances(forced: true),
						for: self.insurance.id
				) {
					self.analytics.track(
						navigationSource: navigationSource,
						insuranceId: self.insurance.id,
						event: selectedClinic.buttonAction == .appointmentOnline
							? AnalyticsEvent.Dms.onlineAppointmentCreate
							: AnalyticsEvent.Dms.offlineAppointmentCreate,
						userProfileProperties: analyticsData.analyticsUserProfileProperties
					)
				}
				
                self.confirmAppointment(
                    viewController: viewController,
                    clinic: clinic
                )
            },
            linkTap: linkTap,
            routeTap: routeInAnotherApp, //routeTap,
            routeInAnotherApp: routeInAnotherApp,
            phoneTap: phoneTap,
            phonesTap: phonesTap
        )
        createAndShowNavigationController(viewController: viewController, mode: .push)
    }

    // MARK: - Appointment
    
    private func confirmAppointment(
        viewController: ViewController,
        clinic: Clinic
    ) {
        if clinic.buttonAction == .appointmentOnline {
            if let onlineClinicAppointmentFlow = self.onlineClinicAppointmentFlow {
                onlineClinicAppointmentFlow.createOnlineDoctorAppointment(clinic: clinic)
            } else {
                let onlineClinicAppointmentFlow = CommonClinicAppointmentFlow(rootController: self.topModalController)
                self.container?.resolve(onlineClinicAppointmentFlow)
                onlineClinicAppointmentFlow.start(clinic: clinic, insurance: self.insurance)
            }
            return
        }
        
        guard self.accountService.isAuthorized
        else { return }
        
        let hide = viewController.showLoadingIndicator(message: nil)
        self.accountService.getAccount(useCache: true) { [weak viewController] result in
            switch result {
                case .success(let userAccount):
                    self.clinicsService.offlineAppointmentSettings(for: clinic.id) { result in
                        hide(nil)
                        switch result {
                            case .success(let settings):
                                let appointment = OfflineAppointment(
                                    id: "",
                                    appointmentNumber: "",
                                    phone: Phone(
                                        plain: userAccount.phone.plain,
                                        humanReadable: userAccount.phone.humanReadable,
                                        voipCall: userAccount.phone.voipCall
                                    ),
                                    date: self.minimumAppointmentDate,
                                    reason: "",
                                    clinicId: clinic.id,
                                    clinic: clinic,
                                    insuranceId: self.insurance.id
                                )
                                self.appointmentInfo(.confirmAppointment(appointment, settings: settings), mode: .push)
                            case .failure(let error):
                                viewController?.processError(error)
                        }
                        
                    }
                case .failure(let error):
                    hide(nil)
                    self.show(error: error)
            }
        }
    }

    private enum AppointmentKind {
        case confirmAppointment(OfflineAppointment, settings: OfflineAppointmentSettings)
        case viewAppointment(OfflineAppointment)
        case appointmentId(String)
    }

    private let minimumAppointmentDate = AppLocale.calendar.date(byAdding: .day, value: 1, to: Date()) ?? Date()
    private var appointmentInfoData: NetworkData<ClinicOfflineAppointmentViewController.Kind> = .loading

    private func appointmentInfo(_ kind: AppointmentKind, mode: ViewControllerShowMode) {
        switch kind {
            case let .confirmAppointment(appointment, settings):
                if let clinic = appointment.clinic {
                    showCreateOfflineAppointment(clinic: clinic, settings: settings)
                }
            case .appointmentId, .viewAppointment:
                showViewOfflineAppointment(kind, mode: mode)
        }
    }

    private func showViewOfflineAppointment(_ kind: AppointmentKind, mode: ViewControllerShowMode) {
        let viewController: ClinicAppointmentViewController = clinicsStoryboard.instantiate()
                viewController.input = ClinicAppointmentViewController.Input(
                    data: { self.appointmentInfoData },
                    insurance: insurance,
                    minimumDate: minimumAppointmentDate
                )
                viewController.output = ClinicAppointmentViewController.Output(
                    createAppointment: { _ in },
                    phoneTap: phoneTap,
                    createCalendarEvent: { appointment in
                        self.createCalendarEvent(appointment: appointment)
                    },
                    refresh: {
                        switch kind {
                            case .confirmAppointment:
                                return
                            case .viewAppointment(let appointment):
                                self.appointmentInfoData = .data(.viewAppointment(appointment))
                                self.notifyUpdate()
                            case .appointmentId(let id):
                                self.loadAppointment(id: id)
                        }
                    }
                )
                if mode == .modal {
                    viewController.addCloseButton { [weak viewController] in
                        viewController?.dismiss(animated: true, completion: nil)
                    }
                }

                notifyChanges.append(viewController.notify.changed)
                createAndShowNavigationController(viewController: viewController, mode: mode)
    }

    private func showCreateOfflineAppointment(
        from commonClinicAppointmentFlow: CommonClinicAppointmentFlow? = nil,
        outdatedAvisId: Int? = nil,
        clinic: Clinic,
        settings: OfflineAppointmentSettings
    ) {
        guard accountService.isAuthorized
        else { return }
        
        var topViewController: UIViewController
        
        if let viewController = navigationController?.topViewController {
            topViewController = viewController
        } else if let viewController = commonClinicAppointmentFlow?.navigationController?.topViewController {
            topViewController = viewController
        } else { return }
        
        let hide = topViewController.showLoadingIndicator(message: nil)
        
        accountService.getAccount(useCache: true) { result in
            hide(nil)
            switch result {
                case .success(let userAccount):
                    // switch between clinics reset user input for custom speciality
                    self.userInputSpecialityText = nil
                    
                    let viewController: ClinicOfflineAppointmentViewController = self.clinicsStoryboard.instantiate()
                    viewController.input = .init(
                        settings: settings,
                        clinic: clinic,
                        userPhone: userAccount.phone,
                        insurance: self.insurance
                    )
                    viewController.output = .init(
                        createAppointment: { [weak self, weak commonClinicAppointmentFlow] data in
                            guard let self = self
                            else { return }
 
                            let request = OfflineAppointmentRequest(
                                phone: data.userPhone,
                                reason: data.reason,
                                clinicId: clinic.id,
                                insuranceId: self.insurance.id,
                                dates: data.dates,
                                clinicSpecialityId: data.speciality.id,
                                userInputForClinicSpeciality: data.userInputForClinicSpeciality,
                                disclaimerAnswer: data.disclaimerAnswer
                            )
                            
                            self.createOfflineAppointment(
                                from: commonClinicAppointmentFlow,
                                outdatedAvisId: outdatedAvisId,
                                offlineAppointmentRequest: request
                            )
                        },
                        selectAppointmentDate: { inputPickedRange, completion in
                            self.showCalendar(inputPickedRange: inputPickedRange, settings: settings, completion: completion)
                        },
                        phoneTap: self.phoneTap,
                        pickDoctor: { selected, completion in
                            self.showOfflineAppointmentDoctorsList(selected: selected, settings: settings, completion: completion)
                        }
                    )

                    self.notifyChanges.append(viewController.notify.changed)
                    self.createAndShowNavigationController(viewController: viewController, mode: .push)
                case .failure(let error):
                    self.show(error: error)
            }
        }
    }
    
    private func createSpecialityTextInput(
        initialText: String,
        completion: ((String) -> Void)?
    ) -> TextAreaInputBottomViewController{
        let controller = TextAreaInputBottomViewController()
        container?.resolve(controller)

        controller.input = .init(
            title: NSLocalizedString("clinic_speciality_title_completion_for_user_input", comment: "").capitalizingFirstLetter(),
            description: nil,
            textInputTitle: nil,
            textInputPlaceholder: NSLocalizedString("", comment: ""),
            initialText: initialText,
            validationRules: [ RequiredValidationRule() ],
            showValidInputIcon: false,
            keyboardType: .default,
            autocapitalizationType: .sentences,
            charsLimited: .limited(100),
            showMaxCharsLimit: true
        )

        controller.output = .init(
            close: { [weak controller] in
                controller?.dismiss(animated: true, completion: nil)
            }, text: { [weak controller] text in
                completion?(text)
                controller?.dismiss(animated: true, completion: nil)
            }
        )
        return controller
    }

    private func showOfflineAppointmentDoctorsList(
        selected: ClinicSpeciality?,
        settings: OfflineAppointmentSettings,
        completion: @escaping (ClinicSpeciality, String?) -> Void
    ) {
        
        let controller = EuroProtocolMultipleChoiceListViewController()
        container?.resolve(controller)
        let selectables = settings.clinicSpecialities.map {
            ClinicSpecialitySelectable(
                clinicSpeciality: ClinicSpeciality(
                    id: $0.id,
                    title: { title, userInputRequired in
                        if let userInputSpecialityText = self.userInputSpecialityText,
                           userInputRequired {
                            return "\(title) (\(userInputSpecialityText))"
                        }
                        
                        if userInputRequired {
                            return "\(title) (\(NSLocalizedString("clinic_speciality_title_completion_for_user_input", comment: "")))"
                        }
                        
                        return title
                    }($0.title, $0.userInputRequired),
                    userInputRequired: $0.userInputRequired
                ),
                isSelected: $0.id == selected?.id
            )
        }
        controller.input = .init(
            canDeselectSingleItem: false,
            title: NSLocalizedString("clinic_appointment_specialist", comment: ""),
            items: selectables,
            maxSelectionNumber: 1,
            buttonTitle: NSLocalizedString("common_save", comment: "")
        )
        
        controller.output = .init(
            save: { indices in
                guard let idx = indices.first
                else { return }

                let speciality = settings.clinicSpecialities[idx]
                completion(speciality, speciality.userInputRequired ? self.userInputSpecialityText : nil)
                self.navigationController?.popViewController(animated: true)
            },
            userInputForSelectedItemHandler: { [weak controller] itemIndex, completion in
                let textInputController = self.createSpecialityTextInput(
                    initialText: self.userInputSpecialityText ?? "",
                    completion: { userInputSpecialityText in
                        self.userInputSpecialityText = userInputSpecialityText
                        
                        let modifiedSpeciality = settings.clinicSpecialities[itemIndex].title
                            + " (" + userInputSpecialityText + ")"
                        completion(modifiedSpeciality)
                    }
                )
                controller?.showBottomSheet(contentViewController: textInputController)
            }
        )
        createAndShowNavigationController(viewController: controller, mode: .push)
    }

    private func loadAppointment(id: String) {
        appointmentInfoData = .loading
        notifyUpdate()
        clinicsService.offlineAppointment(id: id) { [weak self] result in
            guard let self = self else { return }

            switch result {
                case .success(let appointment):
                    self.appointmentInfoData = .data(.viewAppointment(appointment))
                case .failure(let error):
                    self.appointmentInfoData = .error(error)
                    self.show(error: error)
            }
            self.notifyUpdate()
        }
    }

    private func createOfflineAppointment(
        from commonClinicAppointmentFlow: CommonClinicAppointmentFlow? = nil,
        outdatedAvisId: Int? = nil,
        offlineAppointmentRequest: OfflineAppointmentRequest
    ) {
        guard !accountService.isDemo else {
            if let controller = navigationController?.topViewController {
                DemoAlertHelper().showDemoAlert(from: controller)
            }
            return
        }

        appointmentStatusInfoScreen(
            from: commonClinicAppointmentFlow,
            kind: .offlineAppointment
        ) {
            self.createAppointmentRequest(
                outdatedAvisId: outdatedAvisId,
                appointmentRequest: offlineAppointmentRequest
            )
        }
    }
        
    private func showCalendar(inputPickedRange: DateRange?, settings: OfflineAppointmentSettings, completion: @escaping (Date) -> Void) {
        let storyboard = UIStoryboard(name: "VzrOnOffFlow", bundle: nil)
        let viewController: RangeCalendarViewController = storyboard.instantiate()
        container?.resolve(viewController)

        var enabledInterval: DateInterval?
        let enabledStartDate = CalendarDate(Date())?.dateByAdding(years: 0, months: 0, days: settings.minDateDays)
        let enabledEndDate = CalendarDate(Date()).dateByAdding(years: 0, months: 0, days: settings.maxDateDays + 1)

        if let enabledStartDate = enabledStartDate, let enabledEndDate = enabledEndDate {
            enabledInterval = DateInterval(start: enabledStartDate.date, end: enabledEndDate.date)
        }
        viewController.input = .init(
            inputPickedRange: inputPickedRange,
            startingDate: Date(),
            enabledInterval: enabledInterval,
            calendarInterval: nil,
            pickedRangeLengthMin: 1,
            pickedRangeLengthMax: 1,
            theme: .themeDefault,
            calendarType: .appointment
        )
        viewController.output = .init(
            selectedRange: { [weak self] dateRange in
                self?.navigationController?.popViewController(animated: true)
                completion(dateRange.startDate.date)
            }
        )
        createAndShowNavigationController(viewController: viewController, mode: .push)
    }

    // MARK: - Appointment status info

    private var appointmentStatusInfoData: NetworkData<Bool> = .loading

    private func appointmentStatusInfoScreen(
        from commonClinicAppointmentFlow: CommonClinicAppointmentFlow? = nil,
        kind: ClinicAppointmentStatusViewController.Kind,
        operationRequest: @escaping () -> Void
    ) {
        let viewController: ClinicAppointmentStatusViewController = clinicsStoryboard.instantiate()
        // swiftlint:disable:next trailing_closure
        viewController.input = ClinicAppointmentStatusViewController.Input(
            kind: kind,
            data: { self.appointmentStatusInfoData }
        )
        viewController.output = ClinicAppointmentStatusViewController.Output(
            refresh: {
                operationRequest()
            },
            doneTap: { [weak self, weak commonClinicAppointmentFlow] in
                guard let self = self,
                      let navigationController = self.navigationController
                else { return }

                self.navigationController?.viewControllers.removeAll(where: { viewController -> Bool in
                    if viewController.isKind(of: ClinicOfflineAppointmentViewController.self)
                    || viewController.isKind(of: CommonAppointmentInfoViewController.self) {
                        return true
                    } else {
                        return false
                    }
                })
                
                navigationController.popViewController(animated: true)
                
                guard let commonClinicAppointmentFlow = commonClinicAppointmentFlow
                else { return }
                
                commonClinicAppointmentFlow.loadAllApointments()
            }
        )

        viewController.navigationItem.setHidesBackButton(true, animated: false)
        
        notifyChanges.append(viewController.notify.changed)
        createAndShowNavigationController(viewController: viewController, mode: .push, asInitial: false)
    }
    
    private func createAppointmentRequest(
        outdatedAvisId: Int? = nil,
        appointmentRequest appointment: OfflineAppointmentRequest
    ) {
        appointmentStatusInfoData = .loading
        notifyUpdate()
        clinicsService.createOfflineAppointment(
            cancelingAppointmentAvisId: outdatedAvisId,
            appointment
        ) { [weak self] result in
            
            guard let self = self
            else { return }

            switch result {
                case .success:
					if let analyticsData = analyticsData(
						from: self.insurancesService.cachedShortInsurances(forced: true),
						for: insurance.id
					) {
						self.analytics.track(
							insuranceId: insurance.id,
							event: AnalyticsEvent.Clinic.offlineAppointmentDone,
							userProfileProperties: analyticsData.analyticsUserProfileProperties
						)
					}
					
                    self.appointmentStatusInfoData = .data(true)
					
                case .failure(let error):
					if let analyticsData = analyticsData(
						from: self.insurancesService.cachedShortInsurances(forced: true),
						for: insurance.id
					) {
						self.analytics.track(
							insuranceId: insurance.id,
							event: AnalyticsEvent.Clinic.offlineAppointmentError,
							userProfileProperties: analyticsData.analyticsUserProfileProperties
						)
					}
					
                    self.appointmentStatusInfoData = .error(error)
                    self.show(error: error)
					
            }
            self.notifyUpdate()
        }
    }
    
    // MARK: - Helpers

    private func routeTap(_ coordinate: CLLocationCoordinate2D, title: String?) {
        CoordinateHandler.handleCoordinate(coordinate, title: title)
    }
    private func routeInAnotherApp(_ coordinate: CLLocationCoordinate2D, title: String?) {
        guard let currentPosition = currentPosition
        else { return }

        coordinateHandler.handleCoordinateToOpenApps(coordinate, title: title, current: currentPosition)
    }

    private func phoneTap(_ phone: Phone) {
        PhoneHelper.handlePhone(plain: phone.plain, humanReadable: phone.humanReadable)
    }
    private func phonesTap(_ phones: [Phone]) {
        PhoneHelper.handlePhones(phones)
    }

    private func linkTap(_ url: URL) {
        guard let navigationController = navigationController else { return }
        
        SafariViewController.open(url, from: navigationController)
    }

    private func createCalendarEvent(appointment: OfflineAppointment) {
        calendarService.createEvent(
            title: NSLocalizedString("calendar_doctor_event_title", comment: ""),
            notes: nil,
            startDate: appointment.date,
            endDate: appointment.date,
            isAllDay: true,
            locationTitle: appointment.clinic?.title,
            address: appointment.clinic?.address,
            location: appointment.clinic?.coordinate.clLocation
        ) { result in
            DispatchQueue.main.async { [weak self] in
                guard let self = self
                else { return }
                
                switch result {
                    case .success:
                        let text = NSLocalizedString("calendar_event_created", comment: "")
                        self.alertPresenter.show(alert: AddCalendarNotificationAlert(text: text))
                    case .failure(let error):
                        switch error {
                            case .accessDenied:
                                if let rootViewController = self.navigationController {
                                    let controller = UIHelper.findTopModal(controller: rootViewController)
                                    UIHelper.showCalendarRequiredAlert(from: controller)
                                }
                            case .dateInPast, .error:
                                self.show(error: error)
                        }
                }
            }
        }
    }

    static func clinicContainsText(_ clinic: Clinic, _ searchQuery: String) -> Bool
	{
		clinic.title.localizedCaseInsensitiveContains(searchQuery) ||
		clinic.address.localizedCaseInsensitiveContains(searchQuery) ||
		filterUrl(clinicUrl: clinic.url, searchQuery: searchQuery) ||
		filterPhone(clinicPhones: clinic.phoneList ?? [], searchQuery: searchQuery) ||
		filterServiceList(serviceList: clinic.serviceList, searchQuery: searchQuery) ||
		filterMetroList(metroList: clinic.metroList ?? [], searchQuery: searchQuery) ||
		filterLabelList(labelList: clinic.labelList ?? [], searchQuery: searchQuery) ||
		clinic.serviceHours.localizedCaseInsensitiveContains(searchQuery)
    }
	
	private static func filterUrl(clinicUrl: URL?, searchQuery: String) -> Bool
	{
		guard let urlString = clinicUrl?.absoluteString
		else { return false }
		
		
		return urlString.localizedCaseInsensitiveContains(searchQuery)
	}
	
	private static func filterPhone(
		clinicPhones: [Phone],
		searchQuery: String
	) -> Bool
	{
		clinicPhones.contains(
			where: { $0.plain.localizedCaseInsensitiveContains(searchQuery)}
		)
	}
	
	private static func filterServiceList(
		serviceList: [String],
		searchQuery: String
	) -> Bool
	{
		serviceList.contains(
			where: { $0.localizedCaseInsensitiveContains(searchQuery)}
		)
	}
	
	private static func filterMetroList(
		metroList: [ClinicMetro],
		searchQuery: String
	) -> Bool
	{
		metroList.contains(
			where: { $0.title.localizedCaseInsensitiveContains(searchQuery)}
		)
	}
	
	private static func filterLabelList(
		labelList: [ClinicLabelList],
		searchQuery: String
	) -> Bool
	{
		labelList.contains(
			where: { $0.title.localizedCaseInsensitiveContains(searchQuery)}
		)
	}
}

// swiftlint:enable file_length
