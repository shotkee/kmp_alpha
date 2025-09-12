//
//  RestMarksWebService.swift
//  AlfaStrah
//
//  Created by vit on 19.07.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//
import Legacy

class RestMarksWebService: MarksWebService {
    private let rest: FullRestClient

    init(rest: FullRestClient) {
        self.rest = rest
    }
    
    func manageSubscriptionUrl(
        insuranceId: String,
        completion: @escaping (Result<URL, AlfastrahError>) -> Void
    ) {
        rest.read(
            path: "/api/insurances/ns/manage_subscription/deeplink",
            id: nil,
            parameters: [ "insurance_id": insuranceId ],
            headers: [:],
            responseTransformer: ResponseTransformer(key: "url", transformer: UrlTransformer<Any>()),
            completion: mapCompletion(completion)
        )
    }

    func appointBeneficiaryUrl(
        insuranceId: String,
        completion: @escaping (Result<URL, AlfastrahError>) -> Void
    ) {
        rest.read(
            path: "/api/insurances/ns/appoint_beneficiary/deeplink",
            id: nil,
            parameters: [ "insurance_id": insuranceId ],
            headers: [:],
            responseTransformer: ResponseTransformer(key: "url", transformer: UrlTransformer<Any>()),
            completion: mapCompletion(completion)
        )
    }
    
    func editInsuranceAgreementUrl(
        insuranceId: String,
        completion: @escaping (Result<URL, AlfastrahError>) -> Void
    ) {
        rest.read(
            path: "/api/insurances/change/deeplink",
            id: nil,
            parameters: [ "insurance_id": insuranceId ],
            headers: [:],
            responseTransformer: ResponseTransformer(key: "url", transformer: UrlTransformer<Any>()),
            completion: mapCompletion(completion)
        )
    }
}
