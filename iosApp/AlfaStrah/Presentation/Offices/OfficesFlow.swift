//
//  OfficesFlow
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 16/11/2018.
//  Copyright © 2018 RedMadRobot. All rights reserved.
//

import UIKit
import Legacy
import CoreLocation

class OfficesFlow: DependencyContainerDependency,
				   GeolocationServiceDependency,
				   AccountServiceDependency,
				   OfficesServiceDependency,
                   AlertPresenterDependency,
				   LoggerDependency {
    var initialViewController: UINavigationController
    var container: DependencyInjectionContainer?
    var officesService: OfficesService!
    var geoLocationService: GeoLocationService!
    var alertPresenter: AlertPresenter!
    var logger: TaggedLogger?
	var accountService: AccountService!

    private var notifyChanges: [(Insurance.Kind?) -> Void] = []
    private let storyboard = UIStoryboard(name: "Offices", bundle: nil)
    private var insuranceKind: Insurance.Kind? {
        didSet {
            officesFilter = OfficesFilter()
            switch insuranceKind {
                case .osago:
                    officesFilter.addFilter(.osagoClaim)
                case .kasko:
                    officesFilter.addFilter(.claim)
                default:
                    break
            }
        }
    }
    private lazy var coordinateHandler: CoordinateHandler = {
        let handler = CoordinateHandler()
        container?.resolve(handler)
        return handler
    }()

    deinit {
        logger?.debug("")
    }

    init() {
        let navigationController = RMRNavigationController()
        navigationController.strongDelegate = RMRNavigationControllerDelegate()
        initialViewController = navigationController
    }

    private func notifyUpdate(_ filterInsuranceKind: Insurance.Kind?) {
        notifyChanges.forEach { $0(filterInsuranceKind) }
    }

    func start(from navigationController: UINavigationController, with insuranceKind: Insurance.Kind) {
        self.insuranceKind = insuranceKind
        initialViewController = navigationController
        initialViewController.navigationBar.isTranslucent = true
        initialViewController.pushViewController(createOfficePicker(), animated: true)
    }
    
    func start(from fromController: ViewController) {
        let viewController = createOfficePicker()
        viewController.hidesBottomBarWhenPushed = true
        viewController.extendedLayoutIncludesOpaqueBars = true
		
		if let navigationController = fromController.navigationController {
			initialViewController = navigationController
			navigationController.pushViewController(viewController, animated: true)
		} else {
			let navigationController = RMRNavigationController()
			navigationController.strongDelegate = RMRNavigationControllerDelegate()
			
			viewController.addBackButton {
				fromController.dismiss(animated: true)
			}
			
			navigationController.setViewControllers([ viewController ], animated: true)
			fromController.present(navigationController, animated: true, completion: nil)
		}
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
                    let controller = UIHelper.findTopModal(controller: self.initialViewController)
                    UIHelper.showLocationRequiredAlert(from: controller, locationServicesEnabled: true)
                case .restricted:
                    let controller = UIHelper.findTopModal(controller: self.initialViewController)
                    UIHelper.showLocationRequiredAlert(from: controller, locationServicesEnabled: false)
            }
        }

        geoLocationSubscription = geoLocationService.subscribeForLocation { [weak self] deviceLocation in
            guard let `self` = self else { return }

            if deviceLocation != self.currentPosition {
                self.currentPosition = deviceLocation
                self.geoLocationSubscription?.unsubscribe()
                if case .data = self.officesData {
                    self.filterOffices()
                    self.notifyUpdate(self.insuranceKind)
                }
            }

        }
    }

    // MARK: - Office picker
    private func createOfficePicker() -> OfficePickerViewController {
        let viewController: OfficePickerViewController = storyboard.instantiate()
        container?.resolve(viewController)
        viewController.input = OfficePickerViewController.Input(
			isDemo: self.accountService.isDemo,
            selectedFilters: { [weak self] in
                self?.officesFilter
            },
            officesListPickerViewController: officesListViewController(),
            mapPickerViewController: officesMapViewController()
        )
        viewController.output = .init(
            setupLocationServices: { [weak self] in
                self?.setupLocationServices()
            },
            openFiltersScreen: { [weak self] completion in
                self?.showFilters(completion)
            },
            setOfficeFilter: { [weak self] in
                self?.officesFilter = $0
            }
        )
        notifyChanges.append(viewController.notify.changed)
        return viewController
    }

    // MARK: - Offices list

    private var officesData: NetworkData<[Office]> = .loading
    private var citiesData: NetworkData<[City]> = .loading

    private func officesListViewController() -> OfficesListViewController {
        let viewController: OfficesListViewController = storyboard.instantiate()
        container?.resolve(viewController)
        // swiftlint:disable:next trailing_closure
        viewController.input = OfficesListViewController.Input(
            data: {
                self.officesData
            }
        )
        viewController.output = OfficesListViewController.Output(
            office: { [weak self] office in
                self?.showOffice(office)
            },
            refresh: { [weak self] in
                self?.loadOffices()
            }
        )
        notifyChanges.append(viewController.notify.changed)
        return viewController
    }

    private var offices: [Office] = []
    private var cities: [City] = []

    private func loadOffices() {
        officesService.offices { [weak self] result in
            guard let `self` = self else { return }

            switch result {
                case .success(let offices):
                    self.offices = offices
                    self.filterOffices()
                case .failure(let error):
                    self.show(error: error)
                    self.officesData = .error(error)
            }
            self.notifyUpdate(self.insuranceKind)
        }
    }

    private func loadCities() {
        officesService.cities { [weak self] result in
            guard let `self` = self else { return }

            switch result {
                case .success(let cities):
                    self.cities = cities
                    
                    /// self.sort - very long op which blocks main UI thread
                    DispatchQueue.global(qos: .background).async {
                        let sortedCities = self.sort(cities: cities)
                        
                        DispatchQueue.main.async {
                            self.citiesData = .data(sortedCities)
                            self.notifyUpdate(self.insuranceKind)
                            self.logger?.debug("Cities were loaded")
                        }
                    }
                case .failure(let error):
                    self.show(error: error)
                    self.citiesData = .error(error)
                    self.notifyUpdate(self.insuranceKind)
                    self.logger?.debug("Cities were not loaded")
            }
        }
    }

    private func sort(offices: [Office]) -> [Office] {
        if let baseLocation = currentPosition {
            logger?.debug("Sorting by distance")
            return offices
                .map { office in
                    var newOffice = office
                    newOffice.distance = Coordinate.distance(from: baseLocation, to: office.coordinate)
                    return newOffice
                }
                .sorted { ($0.distance ?? 0).isLess(than: $1.distance ?? 0) }
        } else {
            logger?.debug("Sorting by address")
            return offices.sorted { $0.address < $1.address }
        }
    }

    private var officesFilter = OfficesFilter() {
        didSet {
            filterOffices()
        }
    }
    private func filterOffices() {
        officesData = .data(officesFilter.filter(offices: sort(offices: offices)))
        logger?.debug("Offices was filtered")
        notifyUpdate(self.insuranceKind)
    }

    private func sort(cities: [City]) -> [City] {
        var newCities = cities
            .map { City(id: $0.id, title: TextHelper.html(from: $0.title).string) }
            .sorted { $0.title < $1.title }
        if let spbIndex = newCities.firstIndex(where: { $0.id == "774753" }) {
            let spbCity = newCities.remove(at: spbIndex)
            newCities.insert(spbCity, at: 0)
        }
        if let moscowIndex = newCities.firstIndex(where: { $0.id == "709200" }) {
            let moscowCity = newCities.remove(at: moscowIndex)
            newCities.insert(moscowCity, at: 0)
        }
        newCities.insert(City(id: "", title: NSLocalizedString("office_filters_list_position_all_cases", comment: "")), at: 0)
        logger?.debug("Cities was filtered")
        return newCities
    }

    // MARK: - Map

    private func officesMapViewController() -> OfficesMapViewController {
        let viewController: OfficesMapViewController = storyboard.instantiate()
        container?.resolve(viewController)
        viewController.input = OfficesMapViewController.Input(
            userLocation: { [weak self] in
                self?.currentPosition
            },
            defaultLocation: geoLocationService.defaultLocation,
            extremeLocations: geoLocationService.extremeRussiaLocations,
            data: {
                self.officesData
            },
            searchStringIsEmpty: { [weak self] in
                self?.officesFilter.getSearchString()?.isEmpty ?? true
            }
        )
        // swiftlint:disable:next trailing_closure
        viewController.output = OfficesMapViewController.Output(
            office: { [weak self] office in
                self?.showOffice(office)
            },
            routeInAnotherApp: { [weak self] in
                self?.routeInAnotherApp($0, title: nil)
            }
        )
        notifyChanges.append(viewController.notify.changed)
        return viewController
    }

    // MARK: - Office

    private func showOffice(_ office: Office) {
        let viewController: OfficeViewController = storyboard.instantiate()
        container?.resolve(viewController)
        viewController.input = OfficeViewController.Input(office: office)
        viewController.output = OfficeViewController.Output(
            routeTap: routeTap,
            routeInAnotherApp: routeInAnotherApp,
			phoneTap: { [weak viewController] phone in
				
				guard let viewController
				else { return }
				
				if self.accountService.isDemo
				{
					DemoBottomSheet.presentInfoDemoSheet(from: viewController)
				}
				else
				{
					self.phoneTap(phone)
				}
			},
            phonesTap: { [weak viewController] phones in
				
				guard let viewController
				else { return }
				
				if self.accountService.isDemo
				{
					DemoBottomSheet.presentInfoDemoSheet(from: viewController)
				}
				else
				{
					self.phonesTap(phones)
				}
			}
        )
        viewController.hidesBottomBarWhenPushed = true
        initialViewController.pushViewController(viewController, animated: true)
    }

    // MARK: - Filters
    private func showFilters(_ completion: @escaping (OfficesFilter) -> Void ) {
        let viewController: OfficesFiltersViewController = storyboard.instantiate()
        var currentFilter = officesFilter
        let navController = RMRNavigationController(rootViewController: viewController)
        navController.strongDelegate = RMRNavigationControllerDelegate()

        viewController.input = .init(
            preselectedFilters: { currentFilter }
        )
        viewController.output = .init(
            modify: { currentFilter = $0 },
            closeFilterScreen: { navController.dismiss(animated: true, completion: nil) },
            openCitiesScreen: { cities, citiesBack in
                self.showCitiesScreen(in: navController, preselectedCities: cities) { citiesBack($0) }
            },
            backWithFilters: { navController.dismiss(animated: true) { completion(currentFilter) } }
        )
        container?.resolve(viewController)
        initialViewController.present(navController, animated: true)
    }

    private func showCitiesScreen(
        in navController: UINavigationController,
        preselectedCities: [City],
        _ completion: @escaping ([City]
        ) -> Void) {
        let viewController: OfficeCityListViewController = storyboard.instantiate()
        container?.resolve(viewController)
        viewController.input = .init(
            data: { self.citiesData },
            preselectedCities: { preselectedCities }
        )
        viewController.output = .init(
            back: { navController.popViewController(animated: true) },
            backWithCities: { cities in
                navController.popViewController(animated: true)
                completion(cities)
            },
            refresh: { self.loadCities() })

        notifyChanges.append(viewController.notify.changed)
        navController.pushViewController(viewController, animated: true)
    }

    // MARK: - Error handle

    private func show(error: Error) {
        ErrorHelper.show(error: error, alertPresenter: alertPresenter)
    }

    // MARK: - Helpers

    private func routeTap(_ coordinate: CLLocationCoordinate2D, title: String?) {
        CoordinateHandler.handleCoordinate(coordinate, title: title)
    }

    private func routeInAnotherApp(_ coordinate: CLLocationCoordinate2D, title: String?) {
        coordinateHandler.handleCoordinateToOpenApps(coordinate, title: title, current: currentPosition)
    }

    private func phoneTap(_ phone: Phone) {
        PhoneHelper.handlePhone(plain: phone.plain, humanReadable: phone.humanReadable)
    }

    private func phonesTap(_ phones: [Phone]) {
        PhoneHelper.handlePhones(phones)
    }
}
