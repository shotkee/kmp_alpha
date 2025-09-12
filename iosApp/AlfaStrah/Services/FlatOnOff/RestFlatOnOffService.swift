//
//  RestFlatOnOffService.swift
//  AlfaStrah
//
//  Created by Peter Tretyakov on 30.03.2020.
//  Copyright © 2020 Redmadrobot. All rights reserved.
//

import Legacy

class RestFlatOnOffService: FlatOnOffService {
    private let rest: FullRestClient
    private let insurancesService: InsurancesService
    
    private var insurancesRequestIsPending = false
    private var insurancesRequestCompletions: [(Result<[FlatOnOffInsurance], AlfastrahError>) -> Void] = []

    init(rest: FullRestClient, insurancesService: InsurancesService) {
        self.rest = rest
        self.insurancesService = insurancesService
    }

    func insurances(_ completion: @escaping (Result<[FlatOnOffInsurance], AlfastrahError>) -> Void) {
        insurancesService.insurances(useCache: true) { [weak self] result in
            guard let self = self else { return }

            switch result {
                case .success(let insurances):
                    let flatInsurances = insurances.insuranceGroupList
                        .flatMap { $0.insuranceGroupCategoryList.flatMap { $0.insuranceList } }
                        .filter { $0.type == .flatOnOff }
                    guard !flatInsurances.isEmpty else { return completion(.success([])) }
                    
                    self.insurancesRequestCompletions.append(completion)
                    
                    if !self.insurancesRequestIsPending {
                        self.insurancesRequestIsPending = true
                        
                        self.rest.read(
                            path: "api/propertyonoff/insurances",
                            id: nil,
                            parameters: [:],
                            headers: [:],
                            responseTransformer: ResponseTransformer(
                                key: "insurances",
                                transformer: ArrayTransformer(transformer: FlatOnOffInsuranceTransformer())
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

    func balance(insuranceId: String, completion: @escaping (Result<Int, AlfastrahError>) -> Void) {
        rest.read(
            path: "api/propertyonoff/balance",
            id: nil,
            parameters: [ "insurance_id": insuranceId ],
            headers: [:],
            responseTransformer: ResponseTransformer(
                key: "balance",
                transformer: CastTransformer<Any, Int>()
            ),
            completion: mapCompletion(completion)
        )
    }

    func activations(insuranceId: String, completion: @escaping (Result<[FlatOnOffProtection], AlfastrahError>) -> Void) {
        rest.read(
            path: "api/propertyonoff/protection/history",
            id: nil,
            parameters: [ "insurance_id": insuranceId ],
            headers: [:],
            responseTransformer: ResponseTransformer(
                key: "protection_list",
                transformer: ArrayTransformer(transformer: FlatOnOffProtectionTransformer())
            ),
            completion: mapCompletion(completion)
        )
    }

    func activate(
        insuranceId: String,
        start: Date,
        finish: Date,
        completion: @escaping (Result<FlatOnOffProtectionCalculation, AlfastrahError>) -> Void
    ) {
        rest.create(
            path: "api/propertyonoff/protection/calc",
            id: nil,
            object: FlatOnOffActivateRequest(insuranceId: insuranceId, startDate: start, endDate: finish),
            headers: [:],
            requestTransformer: FlatOnOffActivateRequestTransformer(),
            responseTransformer: ResponseTransformer(
                key: "protection",
                transformer: FlatOnOffProtectionCalculationTransformer()
            ),
            completion: mapCompletion(completion)
        )
    }

    func confirmActivation(
        insuranceId: String,
        protectionId: String,
        completion: @escaping (Result<FlatOnOffConfirmActivationResponse, AlfastrahError>) -> Void
    ) {
        rest.create(
            path: "api/propertyonoff/protection/accept",
            id: nil,
            object: FlatOnOffConfirmActivationRequest(insuranceId: insuranceId, protectionId: protectionId),
            headers: [:],
            requestTransformer: FlatOnOffConfirmActivationRequestTransformer(),
            responseTransformer: ResponseTransformer(transformer: FlatOnOffConfirmActivationResponseTransformer()),
            completion: mapCompletion(completion)
        )
    }

    func packages(insuranceId: String, completion: @escaping (Result<[FlatOnOffPurchaseItem], AlfastrahError>) -> Void) {
        rest.read(
            path: "api/propertyonoff/purchase/possible",
            id: nil,
            parameters: [ "insurance_id": insuranceId ],
            headers: [:],
            responseTransformer: ResponseTransformer(
                key: "purchase_list",
                transformer: ArrayTransformer(transformer: FlatOnOffPurchaseItemTransformer())
            ),
            completion: mapCompletion(completion)
        )
    }

    func purchaseUrl(insuranceId: String, packageId: String, completion: @escaping (Result<URL, AlfastrahError>) -> Void) {
        rest.create(
            path: "api/propertyonoff/purchase/deeplink",
            id: nil,
            object: [ "insurance_id": insuranceId, "purchaseitem_id": packageId ],
            headers: [:],
            requestTransformer: DictionaryTransformer(
                keyTransformer: CastTransformer<AnyHashable, String>(),
                valueTransformer: CastTransformer<Any, String>()
            ),
            responseTransformer: ResponseTransformer(key: "url", transformer: UrlTransformer()),
            completion: mapCompletion(completion)
        )
    }

    func landingURL(_ completion: @escaping (Result<URL, AlfastrahError>) -> Void) {
        rest.read(
            path: "api/propertyonoff/landing",
            id: nil,
            parameters: [:],
            headers: [:],
            responseTransformer: ResponseTransformer(key: "url", transformer: CastTransformer<Any, String>()),
            completion: mapCompletion { (result: Result<String, AlfastrahError>) in
                switch result {
                    case .success(let string):
                        if let url = URL(string: string) {
                            completion(.success(url))
                        } else {
                            completion(.failure(.error(FlatOnOffServiceError.decoding)))
                        }
                    case .failure(let error):
                        completion(.failure(error))
                }
            }
        )
    }
}
