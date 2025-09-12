//
//  RestGuaranteeLettersService.swift
//  AlfaStrah
//
//  Created by Vyacheslav Shakaev on 08.04.2022.
//  Copyright © 2022 Touch Instinct. All rights reserved.
//

import Legacy

class RestGuaranteeLettersService: GuaranteeLettersService {
    private let rest: FullRestClient

    init(rest: FullRestClient) {
        self.rest = rest
    }

    func guaranteeLetters(
        insuranceId: String,
        completion: @escaping (Result<[GuaranteeLetter], AlfastrahError>) -> Void
    ){
        rest.read(
            path: "api/insurances/dms/garantee_letters",
            id: nil,
            parameters: ["insurance_id": insuranceId],
            headers: [:],
            responseTransformer: ResponseTransformer(
                key: "garantee_letter_list",
                transformer: ArrayTransformer(transformer: GuaranteeLetterTransformer())
            ),
            completion: mapCompletion(completion)
        )
    }
}
