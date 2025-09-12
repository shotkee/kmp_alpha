//
//  RestVzrOnOffService.swift
//  AlfaStrah
//
//  Created by Amir Nuriev on 10/8/19.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import Legacy

class RestVzrOnOffService: VzrOnOffService, Updatable {
    private enum CacheExpiration {
        static let day = TimeInterval(60 * 60 * 24)
    }

    private let rest: FullRestClient
    private let store: Store
    private let insurancesService: InsurancesService
    private let applicationSettingsService: ApplicationSettingsService
    private let significantLocationChangesService: SignificantLocationChangesService
    private let offlineReverseGeocodeService: OfflineReverseGeocodeService
    private let localNotificationsService: LocalNotificationsService
    private let geoLocationService: GeoLocationService
    private var geoLocationSubscription: Subscription?
    
    private var insurancesRequestIsPending = false
    private var insurancesRequestCompletions: [(Result<[VzrOnOffInsurance], AlfastrahError>) -> Void] = []

    init(rest: FullRestClient,
         store: Store,
         insurancesService: InsurancesService,
         applicationSettingsService: ApplicationSettingsService,
         significantLocationChangesService: SignificantLocationChangesService,
         offlineReverseGeocodeService: OfflineReverseGeocodeService,
         localNotificationsService: LocalNotificationsService,
         geoLocationService: GeoLocationService
    ) {
        self.rest = rest
        self.store = store
        self.insurancesService = insurancesService
        self.applicationSettingsService = applicationSettingsService
        self.significantLocationChangesService = significantLocationChangesService
        self.offlineReverseGeocodeService = offlineReverseGeocodeService
        self.localNotificationsService = localNotificationsService
        self.geoLocationService = geoLocationService
    }

    func insurances(_ completion: @escaping (Result<[VzrOnOffInsurance], AlfastrahError>) -> Void) {
        insurancesService.insurances(useCache: true) { [weak self] result in
            guard let self = self else { return }

            switch result {
                case .success(let insurances):
                    guard
                        insurances
                        .insuranceGroupList
                        .flatMap({ $0.insuranceGroupCategoryList.flatMap { $0.insuranceList } })
                        .contains(where: { $0.type == .vzrOnOff })
                    else {
                        return completion(.success([]))
                    }
                    
                    self.insurancesRequestCompletions.append(completion)
                    
                    if !self.insurancesRequestIsPending {
                        self.insurancesRequestIsPending = true
                        
                        self.rest.read(
                            path: "api/travelonoff/insurances",
                            id: nil,
                            parameters: [:],
                            headers: [:],
                            responseTransformer: ResponseTransformer(
                                key: "insurances",
                                transformer: ArrayTransformer(transformer: VzrOnOffInsuranceTransformer())
                            ),
                            completion: mapCompletion { [weak self] result in
                                guard let self = self
                                else { return }
                                
                                self.insurancesRequestCompletions.forEach { $0(result) }
                                self.insurancesRequestCompletions.removeAll()
                                self.insurancesRequestIsPending = false
                            }
                        )
                    }
                case .failure(let error):
                    completion(.failure(error))
            }
        }
    }

    func dashboard(insuranceId: String, completion: @escaping (Result<VzrOnOffDashboardInfo, AlfastrahError>) -> Void) {
        rest.read(
            path: "api/travelonoff/dashboard",
            id: nil,
            parameters: [ "insurance_id": insuranceId ],
            headers: [:],
            responseTransformer: ResponseTransformer(transformer: VzrOnOffDashboardInfoTransformer()),
            completion: mapCompletion(completion)
        )
    }

    func timePackages(insuranceId: String, completion: @escaping (Result<[VzrOnOffPurchaseItem], AlfastrahError>) -> Void) {
        rest.read(
            path: "api/travelonoff/purchase/possible",
            id: nil,
            parameters: [ "insurance_id": insuranceId ],
            headers: [:],
            responseTransformer: ResponseTransformer(
                key: "purchase_list",
                transformer: ArrayTransformer(transformer: VzrOnOffPurchaseItemTransformer())
            ),
            completion: mapCompletion(completion)
        )
    }

    func tripsHistory(insuranceId: String, completion: @escaping (Result<[VzrOnOffTrip], AlfastrahError>) -> Void) {
        rest.read(
            path: "api/travelonoff/trip/history",
            id: nil,
            parameters: [ "insurance_id": insuranceId ],
            headers: [:],
            responseTransformer: ResponseTransformer(
                key: "trip_list",
                transformer: ArrayTransformer(transformer: VzrOnOffTripTransformer())
            ),
            completion: mapCompletion(completion)
        )
    }

    func purchaseHistory(insuranceId: String, completion: @escaping (Result<[VzrOnOffPurchaseHistoryItem], AlfastrahError>) -> Void) {
        rest.read(
            path: "api/travelonoff/purchase/history",
            id: nil,
            parameters: [ "insurance_id": insuranceId ],
            headers: [:],
            responseTransformer: ResponseTransformer(
                key: "purchase_list",
                transformer: ArrayTransformer(transformer: VzrOnOffPurchaseHistoryItemTransformer())
            ),
            completion: mapCompletion(completion)
        )
    }

    func landingUrl(_ completion: @escaping (Result<String, AlfastrahError>) -> Void) {
        rest.read(
            path: "api/travelonoff/landing",
            id: nil,
            parameters: [:],
            headers: [:],
            responseTransformer: ResponseTransformer(key: "url", transformer: CastTransformer<Any, String>()),
            completion: mapCompletion(completion)
        )
    }

    func programTerms(insuranceId: String, completion: @escaping (Result<VzrOnOffProgramTerms, AlfastrahError>) -> Void) {
        rest.read(
            path: "api/travelonoff/program",
            id: nil,
            parameters: [ "insurance_id": insuranceId ],
            headers: [:],
            responseTransformer: ResponseTransformer(transformer: VzrOnOffProgramTermsTransformer()),
            completion: mapCompletion(completion)
        )
    }

    func activateTrip(
        insuranceId: String,
        startDate: Date,
        endDate: Date,
        completion: @escaping (Result<VzrOnOffActivateTripResponse, AlfastrahError>) -> Void
    ) {
        rest.create(
            path: "api/travelonoff/trip/activate",
            id: nil,
            object: VzrOnOffActivateTripRequest(insuranceId: insuranceId, startDate: startDate, endDate: endDate),
            headers: [:],
            requestTransformer: VzrOnOffActivateTripRequestTransformer(),
            responseTransformer: ResponseTransformer(transformer: VzrOnOffActivateTripResponseTransformer()),
            completion: mapCompletion(completion)
        )
    }

    func purchaseLink(
        insuranceId: String,
        purchaseItemId: String,
        completion: @escaping (Result<String, AlfastrahError>) -> Void
    ) {
        rest.create(
            path: "api/travelonoff/purchase/deeplink",
            id: nil,
            object: PurchaseLinkRequest(insuranceId: insuranceId, purchaseItemId: purchaseItemId),
            headers: [:],
            requestTransformer: PurchaseLinkRequestTransformer(),
            responseTransformer: ResponseTransformer(key: "url", transformer: CastTransformer<Any, String>()),
            completion: mapCompletion(completion)
        )
    }

    func activeTripInsurance(useCache: Bool, completion: @escaping (Result<VzrOnOffInsurance?, AlfastrahError>) -> Void) {
        if
            useCache,
            let cachedInsurance = cachedActiveTripInsurance(),
            let expDate = applicationSettingsService.vzrOnOffActiveTripCacheExpDate,
            expDate > Date()
        {
            toggleCountryMonitoring(.success(cachedInsurance))
            completion(.success(cachedInsurance))
        } else {
            insurances { [weak self] result in
                guard let self = self else { return }

                switch result {
                    case .success(let insurances):
                        if let vzrInsurance = insurances.first(where: { $0.activeTripList.contains(where: { $0.status == .active }) }) {
                            try? self.store.write { transaction in
                                try transaction.delete(type: VzrOnOffInsurance.self)
                                try transaction.insert(vzrInsurance)
                            }
                            self.applicationSettingsService.vzrOnOffActiveTripCacheExpDate = Date(timeIntervalSinceNow: CacheExpiration.day)
                            self.toggleCountryMonitoring(.success(vzrInsurance))
                            completion(.success(vzrInsurance))
                        } else {
                            try? self.store.write { transaction in
                                try transaction.delete(type: VzrOnOffInsurance.self)
                            }
                            if !insurances.isEmpty {
                                self.toggleCountryMonitoring(.success(nil))
                            }
                            completion(.success(nil))
                        }
                    case .failure(let error):
                        self.toggleCountryMonitoring(.failure(error))
                        completion(.failure(error))
                }
            }
        }
    }
    
    func vzrTerminateUrl(insuranceId: String, completion: @escaping (Result<URL, AlfastrahError>) -> Void) {
        rest.read(
            path: "api/insurances/termination",
            id: nil,
            parameters: [ "insurance_id": insuranceId ],
            headers: [:],
            responseTransformer: ResponseTransformer(key: "url", transformer: UrlTransformer<Any>()),
            completion: mapCompletion(completion)
        )
    }
    
    func vzrBonusesUrl(insuranceId: String, completion: @escaping (Result<URL, AlfastrahError>) -> Void) {
        rest.read(
            path: "api/insurances/dms/vzr_bonus",
            id: nil,
            parameters: [ "insurance_id": insuranceId ],
            headers: [:],
            responseTransformer: ResponseTransformer(key: "url", transformer: UrlTransformer<Any>()),
            completion: mapCompletion(completion)
        )
    }
    
    func vzrBonusFranchiseCerificatesUrl(insuranceId: String, completion: @escaping (Result<URL, AlfastrahError>) -> Void) {
        rest.read(
            path: "api/insurances/dms/vzr_bonus_franchise_certificate",
            id: nil,
            parameters: [ "insurance_id": insuranceId ],
            headers: [:],
            responseTransformer: ResponseTransformer(key: "url", transformer: UrlTransformer<Any>()),
            completion: mapCompletion(completion)
        )
    }
    
    func vzrBonusRefundUrl(insuranceId: String, completion: @escaping (Result<URL, AlfastrahError>) -> Void) {
        rest.read(
            path: "api/insurances/dms/vzr_bonus_prepaid_refund",
            id: nil,
            parameters: [ "insurance_id": insuranceId ],
            headers: [:],
            responseTransformer: ResponseTransformer(key: "url", transformer: UrlTransformer<Any>()),
            completion: mapCompletion(completion)
        )
    }
    
    func vzrReports(insuranceId: String, completion: @escaping (Result<[InsuranceReportVZR], AlfastrahError>) -> Void) {
        rest.read(
            path: "/api/insurances/vzr/event_report/list",
            id: nil,
            parameters: [ "insurance_id": insuranceId ],
            headers: [:],
            responseTransformer: ResponseTransformer(
                key: "event_report_list",
                transformer: ArrayTransformer(
                    transformer: InsuranceReportVZRTransformer()
                )
            ),
            completion: mapCompletion(completion)
        )
    }
    
    func vzrReportDetailed(reportId: Int64, completion: @escaping (Result<InsuranceReportVZRDetailed, AlfastrahError>) -> Void) {
        rest.read(
            path: "/api/insurances/vzr/event_report/detailed",
            id: nil,
            parameters: [ "event_report_id": "\(reportId)" ],
            headers: [:],
            responseTransformer: ResponseTransformer(
                key: "event_report_detailed",
                transformer: InsuranceReportVZRDetailedTransformer()
            ),
            completion: mapCompletion(completion)
        )
    }

    func requestPermissionsIfNeeded() {
        guard !applicationSettingsService.vzrOnOffIsLocationRequested else { return }

        geoLocationService.requestAvailability(always: true)
        applicationSettingsService.vzrOnOffIsLocationRequested = true
    }

    private func cachedActiveTripInsurance() -> VzrOnOffInsurance? {
        var insurance: VzrOnOffInsurance?
        try? store.read { transaction in
            insurance = try transaction.select().first
        }
        return insurance
    }

    private func toggleCountryMonitoring(_ activeTripInsurance: Result<VzrOnOffInsurance?, AlfastrahError>) {
        if case .success(let insurance) = activeTripInsurance, insurance == nil {
            self.significantLocationChangesService.start()
            self.geoLocationSubscription = self.significantLocationChangesService.subscribeForLocation { [weak self] coordinate in
                guard let self = self else { return }

                let currentCountry = self.offlineReverseGeocodeService.getCountry(
                    latitude: coordinate.latitude,
                    longitude: coordinate.longitude
                )
                let lastVisitedCountry = Country(rawValue: self.applicationSettingsService.vzrOnOffLastVisitedCountry ?? "") ?? .other
                if lastVisitedCountry == .russia && currentCountry != .russia {
                    self.localNotificationsService.createLocalNotification(kind: .leftCountry)
                }
                self.applicationSettingsService.vzrOnOffLastVisitedCountry = currentCountry.rawValue
            }
        } else {
            self.significantLocationChangesService.stop()
        }
    }

    // MARK: - Updatable

    func updateService(isUserAuthorized: Bool, completion: @escaping (Result<Void, ServiceUpdateError>) -> Void) {
        completion(.failure(.notImplemented))
    }

    func performActionAfterAppIsReady(isUserAuthorized: Bool, completion: @escaping (Result<Void, ServiceUpdateError>) -> Void) {
        completion(.failure(.notImplemented))
    }

    func erase(logout: Bool) {
        try? self.store.write { transaction in
            try transaction.delete(type: VzrOnOffInsurance.self)
        }
    }

}
