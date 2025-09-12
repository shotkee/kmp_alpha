//
//  RestInteractiveSupportService.swift
//  AlfaStrah
//
//  Created by vit on 18.10.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

import Legacy

class RestInteractiveSupportService: InteractiveSupportService {
    private let rest: FullRestClient
    private let store: Store
    private let authorizer: HttpRequestAuthorizer
        
    init(
        rest: FullRestClient,
        store: Store,
        authorizer: HttpRequestAuthorizer
    ) {
        self.rest = rest
        self.store = store
        self.authorizer = authorizer
    }
    
    func onboarding(
        insuranceIds: [String],
        completion: @escaping (Result<[InteractiveSupportData], AlfastrahError>) -> Void
    ) {
        
        let parameters = Dictionary(
            uniqueKeysWithValues: insuranceIds.enumerated().map{ ("insurance_id_list[\($0)]", $1) }
        )
        
        rest.read(
            path: "/api/virtual_assistant/onboarding/data",
            id: nil,
            parameters: parameters,
            headers: [:],
            responseTransformer: ResponseTransformer(
                key: "onboarding_data",
                transformer: ArrayTransformer(transformer: InteractiveSupportDataTransformer())
            ),
            completion: mapCompletion(completion)
        )
    }
    
    func questions(
        insuranceId: String,
        completion: @escaping (Result<InteractiveSupportQuestionsResponse, AlfastrahError>) -> Void
    ) {
        rest.read(
            path: "/api/virtual_assistant/onboarding/questionnaire",
            id: nil,
            parameters: [ "insurance_id": insuranceId ],
            headers: [:],
            responseTransformer: ResponseTransformer(transformer: InteractiveSupportQuestionsResponseTransformer()),
            completion: mapCompletion(completion)
        )
    }
    
    func applyResult(
        insuranceId: String,
        onboardingResultKey: String,
        completion: @escaping (Result<[InteractiveSupportQuestionnaireResult], AlfastrahError>) -> Void
    ) {
        rest.create(
            path: "/api/virtual_assistant/onboarding/result",
            id: nil,
            object: [
                "insurance_id": insuranceId,
                "result_key": onboardingResultKey,
                "timezone": AppLocale.currentTimezoneISO8601()
            ],
            headers: [:],
            requestTransformer: DictionaryTransformer(
                keyTransformer: CastTransformer<AnyHashable, String>(),
                valueTransformer: CastTransformer<Any, String>()
            ),
            responseTransformer: ResponseTransformer(
                key: "result_list",
                transformer: ArrayTransformer(transformer: InteractiveSupportQuestionnaireResultTransformer())
            ),
            completion: mapCompletion(completion)
        )
    }
    
    // MARK: - Onboarding
    func showOnboarding(insuranceId: String) -> Bool {
        var entries: [InteractiveSupportOnboardingShowEntry]?
        
        try? store.read { transaction in
            entries = try transaction.select()
        }
        
        guard let entries
        else { return true }
        
        if entries.contains(where: { $0.insuranceId == insuranceId }) {
            return false
        }
        
        return true
    }
    
    func onboardingWasShownForInsurance(with insuranceId: String) {
        let entry = InteractiveSupportOnboardingShowEntry(insuranceId: insuranceId)
        
        try? self.store.write { transaction in
            try transaction.insert(entry)
        }
    }
    
    // MARK: - Updatable
    
    func erase(logout: Bool) {
        try? store.write { transaction in
            try transaction.delete(type: InteractiveSupportOnboardingShowEntry.self)
        }
    }
    
    func updateService(isUserAuthorized: Bool, completion: @escaping (Result<Void, ServiceUpdateError>) -> Void) {
        completion(.failure(.notImplemented))
    }

    func performActionAfterAppIsReady(isUserAuthorized: Bool, completion: @escaping (Result<Void, ServiceUpdateError>) -> Void) {
        completion(.success(()))
    }
}
