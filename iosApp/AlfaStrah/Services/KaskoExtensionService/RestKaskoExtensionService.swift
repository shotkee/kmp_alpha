//
//  RestKaskoExtensionService.swift
//  AlfaStrah
//
//  Created by vit on 10.03.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//
import Legacy

class RestKaskoExtensionService: KaskoExtensionService {
    private let rest: FullRestClient

    init(rest: FullRestClient) {
        self.rest = rest
    }
    
    func kaskoExtensionUrl(insuranceId: String, completion: @escaping (Result<URL, AlfastrahError>) -> Void) {
        rest.read(
            path: "api/insurances/kasko/expansion/deeplink",
            id: nil,
            parameters: [ "insurance_id": insuranceId ],
            headers: [:],
            responseTransformer: ResponseTransformer(key: "url", transformer: UrlTransformer<Any>()),
            completion: mapCompletion(completion)
        )
    }
}
