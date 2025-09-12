//
//  RestApiStatusService.swift
//  AlfaStrah
//
//  Created by Vitaly Shkinev on 21.11.2022.
//  Copyright © 2022 Touch Instinct. All rights reserved.
//

import Legacy

class RestApiStatusService: ApiStatusService {
    private let rest: FullRestClient
    private let userAgent: String

    init(rest: FullRestClient, userAgent: String) {
        self.rest = rest
        self.userAgent = userAgent
    }
    
    func apiStatus(completion: @escaping (Result<ApiStatus, AlfastrahError>) -> Void) {
        rest.read(
            path: "/api/status/",
            id: nil,
            parameters: [:],
            headers: ["UserAgent": userAgent],
            responseTransformer: ResponseTransformer(
                key: "api_status",
                transformer: ApiStatusTransformer()
            ),
            completion: mapCompletion(completion)
        )
    }
}
