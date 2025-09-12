//
//  RestInsurancesService
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 05/12/2018.
//  Copyright © 2018 Redmadrobot. All rights reserved.
//

import Legacy

// swiftlint:disable file_length

class RestInsurancesService: InsurancesService {
    private let rest: FullRestClient
    private let store: Store
    private let applicationSettingsService: ApplicationSettingsService
    
    private var singleInsuranceUpdateSubscriptions = Subscriptions<Insurance>()
    
    private var insurancesRequestIsPending = false
    private var insurancesRequestCompletions: [(Result<InsuranceMain, AlfastrahError>) -> Void] = []
    private var sosInsuredRequestIsPending = false
    private var sosInsuredRequestCompletions: [(Result<[SosInsured], AlfastrahError>) -> Void] = []
    
    init(
        rest: FullRestClient,
        store: Store,
        applicationSettingsService: ApplicationSettingsService
    ) {
        self.rest = rest
        self.store = store
        self.applicationSettingsService = applicationSettingsService
    }

    // MARK: - Cached

    func cachedInsurances() -> [Insurance] {
        var insurances: [Insurance] = []
        try? store.read { transaction in
            insurances = try transaction.select()
        }
        return insurances
    }

    func cachedShortInsurances(forced: Bool) -> InsuranceMain? {
        guard let insurances = cachedShortInsurances()
        else { return nil }

        if forced {
            return insurances
        } else {
            if let expDate = applicationSettingsService.insuranceCacheExpDate, expDate > Date() {
                return insurances
            } else {
                return nil
            }
        }
    }
	
	func cachedShortInsurance(by id: String) -> InsuranceShort? {
		guard let insurances = cachedShortInsurances()
		else { return nil }
		
		return insurances.insuranceGroupList
			.flatMap { $0.insuranceGroupCategoryList }
			.flatMap { $0.insuranceList }
			.filter { $0.id == id }.first
	}
    
    func cacheAnonymousSos(
        sosList: [SosModel],
        sosEmergencyCommunication: SosEmergencyCommunication?
    ) {
        let anonymousSos: AnonymousSos = .init(
            sosList: sosList,
            sosEmergencyCommunication: sosEmergencyCommunication
        )
        
        try? store.write { transaction in
            try transaction.delete(type: AnonymousSos.self)
            try transaction.insert(anonymousSos)
        }
    }
    
    func cachedAnonymousSos() -> AnonymousSos? {
        var anonymousSos: [AnonymousSos] = []
        try? store.read { transaction in
            anonymousSos = try transaction.select()
        }
        return anonymousSos.first
    }

    private func cachedShortInsurances() -> InsuranceMain? {
        var insurances: [InsuranceMain] = []
        try? store.read { transaction in
            insurances = try transaction.select()
        }
        return insurances.first
    }
    
    func cachedSosInsured() -> [SosInsured] {
        var sosInsured: [SosInsured] = []
        try? store.read { transaction in
            sosInsured = try transaction.select()
        }
        return sosInsured
    }

    func cachedInsurances(owner: InsuranceOwnerKind, includeArchive: Bool) -> [Insurance] {
        let ownerPredicate: NSPredicate
        switch owner {
            case .me:
                ownerPredicate = NSPredicate(format: "isInsurer == true")
            case .forMe:
                ownerPredicate = NSPredicate(format: "isInsurer == false")
        }
        var insurances: [Insurance] = []
        try? store.read { transaction in
            insurances = try transaction.select(predicate: ownerPredicate)
        }
        return insurances.filter { includeArchive ? true : !$0.isArchive }
    }

    func cachedInsurance(id: String) -> Insurance? {
        var insurance: Insurance?
        try? store.read { transaction in
            insurance = try transaction.select(id: id)
        }
        return insurance
    }
        
    func updateCache(for insurance: Insurance) {
        try? self.store.write { transaction in
            try transaction.upsert(insurance)
        }
    }

    func cachedInsuranceCategories() -> [InsuranceCategory] {
        var categories: [InsuranceCategory] = []
        try? store.read { transaction in
            categories = try transaction.select()
        }
        return categories
    }
    
    func subscribeForSingleInsuranceUpdate(listener: @escaping (Insurance) -> Void) -> Subscription {
        singleInsuranceUpdateSubscriptions.add(listener)
    }
    
    func resetPassengersInsurances() {
        try? store.write { transaction in
            try transaction.delete(
                type: Insurance.self,
                predicate: .init(
                    format: "type == %d",
                    Insurance.Kind.passengers.rawValue
                )
            )
        }
    }
    
    // MARK: - Insurances Rest
    func insurances(useCache: Bool, completion: @escaping (Result<InsuranceMain, AlfastrahError>) -> Void) {
        if useCache, let insurance = cachedShortInsurances(forced: false) {
            completion(.success(insurance))
        } else {
            insurancesRequestCompletions.append(completion)
            
            if !insurancesRequestIsPending {
                insurancesRequestIsPending = true
                
                rest.read(
                    path: "api/insurances",
                    id: nil,
                    parameters: [:],
                    headers: [:],
                    responseTransformer: ResponseTransformer(
                        transformer: InsuranceMainTransformer()
                    ),
                    completion: mapCompletion { [weak self] result in
                        guard let self = self
                        else { return }
                        
                        if case .success(let insuranceMain) = result {
                            try? self.store.write { transaction in
                                try transaction.delete(type: InsuranceMain.self)
                                try transaction.insert(insuranceMain)
                            }
                            self.applicationSettingsService.insuranceCacheExpDate = Date(timeIntervalSinceNow: CacheExpiration.day)
                            if insuranceMain.sosList.contains(
                                where: { $0.isHealthFlow }
                            ) {
                                self.emergencyHelp(
                                    useCache: false,
                                    completion: { _ in }
                                )
                            }
                        }
                        
                        self.insurancesRequestCompletions.forEach { $0(result) }
                        self.insurancesRequestCompletions.removeAll()
                        self.insurancesRequestIsPending = false
                    }
                )
            }
        }
    }
    
    func activateBoxProduct(
        _ insuranceActivateRequest: InsuranceActivateRequest,
        completion: @escaping (Result<InsuranceActivateResponse, AlfastrahError>) -> Void
    ) {
        rest.create(
            path: "/insurances/activate",
            id: nil,
            object: InsuranceActivateRequestParameter(insuranceActivateRequest: insuranceActivateRequest),
            headers: [:],
            requestTransformer: InsuranceActivateRequestParameterTransformer(),
            responseTransformer: ResponseTransformer(transformer: InsuranceActivateResponseTransformer()),
            completion: mapCompletion(completion)
        )
    }

    func insurance(useCache: Bool, ids: [String], completion: @escaping (Result<[Insurance], AlfastrahError>) -> Void) {
        var errors: [AlfastrahError] = []
        var insurances: [Insurance] = []

        let group = DispatchGroup()
        for id in ids {
            group.enter()
            insurance(useCache: useCache, id: id) { response in
                switch response {
                    case .success(let insurance):
                        insurances.append(insurance)
                    case .failure(let error):
                        errors.append(error)
                }
                group.leave()
            }
        }
        group.notify(queue: .main) {
            if let error = errors.first {
                completion(.failure(error))
                return
            }
            completion(.success(insurances))
        }
    }

    func insurance(useCache: Bool, id: String, completion: @escaping (Result<Insurance, AlfastrahError>) -> Void) {
        if useCache, let insurance = cachedInsurance(id: id) {
            completion(.success(insurance))
        } else {
            rest.read(
                path: "insurances_v3/\(id)",
                id: nil,
                parameters: [:],
                headers: [:],
                responseTransformer: ResponseTransformer(
                    key: "insurance",
                    transformer: InsuranceTransformer()
                ),
                completion: mapCompletion { result in
                    if case .success(let insurance) = result {
                        try? self.store.write { transaction in
                            try transaction.upsert(insurance)
                        }
                        
                        self.singleInsuranceUpdateSubscriptions.fire(insurance)
                    }
                    
                    completion(result)
                }
            )
        }
    }
    
    func updateInsurance(id: String) {
        insurance(
            useCache: false,
            id: id,
            completion: { _ in }
        )
    }
    
    func allInsurances(completion: @escaping (Result<[Insurance], AlfastrahError>) -> Void) {
        let group = DispatchGroup()
        var networkError: AlfastrahError?

        group.enter()
        insurances(owner: .me, includeArchive: false) { result in
            if case .failure(let error) = result {
                networkError = error
            }
            group.leave()
        }

        group.enter()
        insurances(owner: .forMe, includeArchive: false) { result in
            if case .failure(let error) = result {
                networkError = error
            }
            group.leave()
        }

        group.notify(queue: .main) {
            if let error = networkError {
                completion(.failure(error))
            } else {
                completion(.success(self.cachedInsurances()))
            }
        }
    }

    func insurances(
        owner: InsuranceOwnerKind,
        includeArchive: Bool,
        completion: @escaping (Result<[Insurance], AlfastrahError>) -> Void
    ) {
        let ownerPredicate: NSPredicate
        let path: String
        switch owner {
            case .me:
                path = "insurances_v3"
                ownerPredicate = NSPredicate(format: "isInsurer == true")
            case .forMe:
                path = "insurances_v3/no_insurer"
                ownerPredicate = NSPredicate(format: "isInsurer == false")
        }
        rest.read(
            path: path,
            id: nil,
            parameters: ["show_archive": includeArchive ? "1" : "0"],
            headers: [:],
            responseTransformer: ResponseTransformer(
                key: "insurance_list",
                transformer: ArrayTransformer(transformer: InsuranceTransformer())
            ),
            completion: mapCompletion { result in
                if case .success(let insurances) = result {
                    try? self.store.write { transaction in
                        try transaction.delete(type: Insurance.self, predicate: ownerPredicate)
                        try transaction.upsert(insurances)
                    }
                }
                completion(result)
            }
        )
    }

    func insuranceCategories(completion: @escaping (Result<[InsuranceCategory], AlfastrahError>) -> Void) {
        rest.read(
            path: "insurances/categories",
            id: nil,
            parameters: [:],
            headers: [:],
            responseTransformer: ResponseTransformer(
                key: "insurance_category_list",
                transformer: ArrayTransformer(transformer: InsuranceCategoryTransformer())
            ),
            completion: mapCompletion { result in
                if case .success(let categories) = result {
                    try? self.store.write { transaction in
                        try transaction.delete(type: InsuranceCategory.self)
                        try transaction.upsert(categories)
                    }
                }
                completion(result)
            }
        )
    }

    func insuranceProducts(completion: @escaping (Result<[InsuranceProduct], AlfastrahError>) -> Void) {
        rest.read(
            path: "insurances/products",
            id: nil,
            parameters: [:],
            headers: [:],
            responseTransformer: ResponseTransformer(
                key: "insurance_product_list",
                transformer: ArrayTransformer(transformer: InsuranceProductTransformer())
            ),
            completion: mapCompletion(completion)
        )
    }

    func insuranceProductDealers(ownershipType: OwnershipType, completion: @escaping (Result<[InsuranceDealer], AlfastrahError>) -> Void) {
        rest.read(
            path: "/insurances/products/dealers",
            id: nil,
            parameters: [ "ownership": "\(ownershipType.rawValue)" ],
            headers: [:],
            responseTransformer: ResponseTransformer(
                key: "dealers_list",
                transformer: ArrayTransformer(transformer: InsuranceDealerTransformer())
            ),
            completion: mapCompletion(completion)
        )
    }

    func insuranceProductDealerPrices(dealerId: String, completion: @escaping (Result<[Money], AlfastrahError>) -> Void) {
        rest.read(
            path: "/insurances/products/price",
            id: nil,
            parameters: [ "dealer_id": dealerId ],
            headers: [:],
            responseTransformer: ResponseTransformer(
                key: "price_list",
                transformer: ArrayTransformer(transformer: MoneyTransformer())
            ),
            completion: mapCompletion(completion)
        )
    }

    func insuranceSearchPolicyRequests(completion: @escaping (Result<[InsuranceSearchPolicyRequest], AlfastrahError>) -> Void) {
        rest.read(
            path: "insurances/search_policy_request/list/v2",
            id: nil,
            parameters: [:],
            headers: [:],
            responseTransformer: ResponseTransformer(
                key: "search_policy_request_list",
                transformer: ArrayTransformer(transformer: InsuranceSearchPolicyRequestTransformer())
            ),
            completion: mapCompletion(completion)
        )
    }

    func insuranceSearchPolicyProducts(completion: @escaping (Result<[InsuranceSearchPolicyProduct], AlfastrahError>) -> Void) {
        rest.read(
            path: "insurances/search_policy_request/products",
            id: nil,
            parameters: [:],
            headers: [:],
            responseTransformer: ResponseTransformer(
                key: "insurance_search_policy_product_list",
                transformer: ArrayTransformer(transformer: InsuranceSearchPolicyProductTransformer())
            ),
            completion: mapCompletion(completion)
        )
    }

    func insuranceSearchPolicyRequestCreate(policyId: String, insuranceNumber: String, date: Date?, photo: UIImage?,
            completion: @escaping (Result<InsuranceSearch, AlfastrahError>) -> Void) {
        var requestArray: [Multipart] = []
        requestArray.append(Multipart(name: "insurance_search_policy_product_id", string: policyId))
        requestArray.append(Multipart(name: "insurance_number", string: insuranceNumber))
        if let issueDate = date {
            let dateString = Constants.dateFormatter.string(from: issueDate)
            requestArray.append(Multipart(name: "issue_date", string: dateString))
        }

        if let image = photo, let fileData = image.jpegData(compressionQuality: 1.0) {
            let photoFile = Multipart(
                name: "image",
                imageData: fileData,
                fileName: "\(fileData.hashValue)",
                contentType: "image/jpg"
            )
            requestArray.append(photoFile)
        }

        rest.create(
            path: "insurances/search_policy_request/create/v2",
            id: nil,
            object: requestArray,
            headers: [:],
            requestSerializer: MultipartSerializer(),
            responseSerializer: JsonModelTransformerHttpSerializer(
                transformer: ResponseTransformer(transformer: InsuranceSearchTransformer())
            ),
            completion: mapCompletion(completion)
        )
    }

    func insuranceSearchPolicyRequestNotify(policyId: String, completion: @escaping (Result<Void, AlfastrahError>) -> Void) {
        rest.create(
            path: "insurances/search_policy_request/notify",
            id: nil,
            object: InsuranceSearchNotify(id: policyId),
            headers: [:],
            requestTransformer: InsuranceSearchNotifyTransformer(),
            responseTransformer: VoidTransformer(),
            completion: mapCompletion(completion)
        )
    }

    // MARK: - Updatable

    func updateService(isUserAuthorized: Bool, completion: @escaping (Result<Void, ServiceUpdateError>) -> Void) {
        completion(.failure(.notImplemented))
    }

    func performActionAfterAppIsReady(isUserAuthorized: Bool, completion: @escaping (Result<Void, ServiceUpdateError>) -> Void) {
        completion(.success(()))
    }

    func erase(logout: Bool) {
        try? store.write { transaction in
            try transaction.delete(type: SosInsured.self)
            try transaction.delete(type: Insurance.self)
            try transaction.delete(type: InsuranceCategory.self)
            try transaction.delete(type: InsuranceMain.self)
        }
    }

    /// Background update insurances
    private func updateInsuranceList(isUserAuthorized: Bool) {
        insuranceCategories { _ in }
    }

    // MARK: - URL Rest

    func insuranceRenewUrl(insuranceID: String, completion: @escaping (Result<URL, AlfastrahError>) -> Void) -> NetworkTask {
        rest.read(
            path: "insurances/\(insuranceID)/renew_url",
            id: nil,
            parameters: [:],
            headers: [:],
            responseTransformer: ResponseTransformer(key: "renew_url", transformer: UrlTransformer()),
            completion: mapCompletion(completion)
        )
    }

    func osagoChangeUrl(insuranceID: String, completion: @escaping (Result<URL, AlfastrahError>) -> Void) -> NetworkTask {
        rest.read(
            path: "/api/insurances/osago/change/deeplink/",
            id: nil,
            parameters: ["insurance_id": "\(insuranceID)"],
            headers: [:],
            responseTransformer: ResponseTransformer(key: "url", transformer: UrlTransformer()),
            completion: mapCompletion(completion)
        )
    }
    
    func osagoTerminationUrl(insuranceID: String, completion: @escaping (Result<URL, AlfastrahError>) -> Void) -> NetworkTask {
        rest.read(
            path: "/api/insurances/osago/termination/deeplink/",
            id: nil,
            parameters: ["insurance_id": "\(insuranceID)"],
            headers: [:],
            responseTransformer: ResponseTransformer(key: "url", transformer: UrlTransformer()),
            completion: mapCompletion(completion)
        )
    }
    
    func reportOnWebsiteUrl(insuranceID: String, completion: @escaping (Result<URL, AlfastrahError>) -> Void) -> NetworkTask {
        rest.read(
            path: "/api/insurances/mainpage/deeplink",
            id: nil,
            parameters: ["insurance_id": "\(insuranceID)"],
            headers: [:],
            responseTransformer: ResponseTransformer(key: "url", transformer: UrlTransformer()),
            completion: mapCompletion(completion)
        )
    }

    func insuranceFromListedProductsDeeplinkUrl(
        productId: String,
        completion: @escaping (Result<URL, AlfastrahError>) -> Void
    ) -> NetworkTask {
        rest.read(
            path: "insurances/products/links/\(productId)/deeplink",
            id: nil,
            parameters: [:],
            headers: [:],
            responseTransformer: ResponseTransformer(key: "deeplink", transformer: UrlTransformer()),
            completion: mapCompletion(completion)
        )
    }

    func insuranceFromPreviousPurchaseDeeplinkUrl(
        productId: String,
        completion: @escaping (Result<URL, AlfastrahError>) -> Void
    ) -> NetworkTask {
        rest.read(
            path: "insurances/new_url",
            id: nil,
            parameters: ["product_id": productId],
            headers: [:],
            responseTransformer: ResponseTransformer(key: "new_url", transformer: UrlTransformer()),
            completion: mapCompletion(completion)
        )
    }

    func renewUrlTerms(insuranceID: String, completion: @escaping (Result<OsagoProlongationURLs, AlfastrahError>) -> Void) {
        rest.read(
            path: "insurances/\(insuranceID)/renew_url_terms",
            id: nil,
            parameters: [:],
            headers: [:],
            responseTransformer: ResponseTransformer(transformer: OsagoProlongationURLsTransformer()),
            completion: mapCompletion(completion)
        )
    }

    func renewPrice(insuranceID: String, completion: @escaping (Result<InsuranceCalculation, AlfastrahError>) -> Void) {
        rest.read(
            path: "insurances/\(insuranceID)/renew_url_calc",
            id: nil,
            parameters: [:],
            headers: [:],
            responseTransformer: ResponseTransformer(transformer: InsuranceCalculationTransformer()),
            completion: mapCompletion(completion)
        )
    }

    func renewPriceProperty(insuranceID: String, completion: @escaping (Result<PropertyRenewCalcResponse, AlfastrahError>) -> Void) {
        rest.read(
            path: "insurances/\(insuranceID)/renew_url_calc_estate",
            id: nil,
            parameters: [:],
            headers: [:],
            responseTransformer: ResponseTransformer(transformer: PropertyRenewCalcResponseTransformer()),
            completion: mapCompletion(completion)
        )
    }

    func renewInsurance(
        insuranceID: String,
        points: Int,
        agreedToPersonalDataPolicy: Bool,
        completion: @escaping (Result<URL, AlfastrahError>) -> Void
    ) {
        rest.create(
            path: "insurances/\(insuranceID)/renew_url_deeplink/",
            id: nil,
            object: RenewInsuranceRequest(
                insurancePonts: points,
                agreedToPersonalDataPolicy: agreedToPersonalDataPolicy
            ),
            headers: [:],
            requestTransformer: RenewInsuranceRequestTransformer(),
            responseTransformer: ResponseTransformer(key: "renew_url", transformer: UrlTransformer()),
            completion: mapCompletion(completion)
        )
    }

    func renewOnWebInsurance(insuranceID: String, completion: @escaping (Result<URL, AlfastrahError>) -> Void) -> NetworkTask {
        rest.create(
            path: "insurances/\(insuranceID)/renew_url_osago/",
            id: nil,
            object: nil,
            headers: [:],
            requestTransformer: VoidTransformer(),
            responseTransformer: ResponseTransformer(key: "deeplink", transformer: UrlTransformer()),
            completion: mapCompletion(completion)
        )
    }

    func telemedicineUrl(insuranceId: String, completion: @escaping (Result<URL, AlfastrahError>) -> Void) {
        rest.read(
            path: "telemed/redirect",
            id: nil,
            parameters: ["insurance_id": "\(insuranceId)"],
            headers: [:],
            responseTransformer: ResponseTransformer(key: "url", transformer: UrlTransformer()),
            completion: mapCompletion(completion)
        )
    }

    func telemedicineUrl(
        notificationId: String,
        insuranceId: String?,
        completion: @escaping (Result<URL, AlfastrahError>) -> Void
    ) {
        var parameters: [String: String] = ["notification_id": "\(notificationId)"]
        
        if let insuranceId = insuranceId {
            parameters["insurance_id"] = insuranceId
        }
        
        rest.read(
            path: "telemed/notification/redirect",
            id: nil,
            parameters: parameters,
            headers: [:],
            responseTransformer: ResponseTransformer(key: "url", transformer: UrlTransformer()),
            completion: mapCompletion(completion)
        )
    }
    
    func emergencyHelp(
        useCache: Bool,
        completion: @escaping (Result<[SosInsured], AlfastrahError>) -> Void
    ) {
        let sosInsured = cachedSosInsured()
        
        if useCache, !sosInsured.isEmpty {
            completion(.success(sosInsured))
        } else {
            sosInsuredRequestCompletions.append(completion)
            
            if !sosInsuredRequestIsPending {
                sosInsuredRequestIsPending = true
                
                rest.read(
                    path: "/api/emergency_help",
                    id: nil,
                    parameters: [:],
                    headers: [:],
                    responseTransformer: ResponseTransformer(
                        key: "insured",
                        transformer: ArrayTransformer(
                            transformer: SosInsuredTransformer()
                        )
                    ),
                    completion: mapCompletion { [weak self] result in
                        guard let self
                        else { return }
                        
                        if case .success(let sosInsured) = result {
                            try? self.store.write { transaction in
                                try transaction.delete(type: SosInsured.self)
                                try transaction.insert(sosInsured)
                            }
                        }
                        
                        self.sosInsuredRequestCompletions.forEach { $0(result) }
                        self.sosInsuredRequestCompletions.removeAll()
                        self.sosInsuredRequestIsPending = false
                    }
                )
            }
        }
    }
	
	func addConfidant(
		name: String,
		phone: String,
		completion: @escaping (Result<InfoMessage, AlfastrahError>) -> Void
	) {
		rest.create(
			path: "/api/confidant/add",
			id: nil,
			object: [
				"name": name,
				"phone": phone
			],
			headers: [:],
			requestTransformer: DictionaryTransformer(
				keyTransformer: CastTransformer<AnyHashable, String>(),
				valueTransformer: CastTransformer<Any, String>()
			),
			responseTransformer: ResponseTransformer(key: "info_message", transformer: InfoMessageTransformer()),
			completion: mapCompletion(completion)
		)
	}
	
	func deleteConfidant(completion: @escaping (Result<InfoMessage, AlfastrahError>) -> Void) {
		rest.create(
			path: "/api/confidant/delete",
			id: nil, 
			object: nil,
			headers: [:],
			requestTransformer: VoidTransformer(),
			responseTransformer: ResponseTransformer(key: "info_message", transformer: InfoMessageTransformer()),
			completion: mapCompletion(completion)
		)
	}
	
	func checkOsagoBlock(completion: @escaping (Result<CheckOsagoBlock, AlfastrahError>) -> Void)
	{
		rest.read(
			path: "/api/rsa/check_osago_second_participant_block",
			id: nil,
			parameters: [:],
			headers: [:],
			responseTransformer: ResponseTransformer(key: "check_osago_block", transformer: CheckOsagoBlockTransformer()),
			completion: mapCompletion(completion)
		)
	}
    
    func cancelEmergencyHelp() {
        self.sosInsuredRequestCompletions.removeAll()
        self.sosInsuredRequestIsPending = false
    }

    private enum Constants {
        static let dateFormatter: DateFormatter = {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-mm-dd"
            dateFormatter.locale = Locale.current
            dateFormatter.timeZone = TimeZone.current
            return dateFormatter
        }()
    }
    
    enum CacheExpiration {
        static let day = TimeInterval(60 * 60 * 24)
    }
}
