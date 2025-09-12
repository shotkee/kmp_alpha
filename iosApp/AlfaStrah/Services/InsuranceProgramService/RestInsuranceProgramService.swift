//
//  RestInsuranceProgramService.swift
//  AlfaStrah
//
//  Created by mac on 19.11.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

import Legacy

class RestInsuranceProgramService: InsuranceProgramService {
    private let rest: FullRestClient

    init(rest: FullRestClient) {
        self.rest = rest
    }

    func getHelpBlocks(insuranceId: String, completion: @escaping (Result<[InsuranceProgramHelpBlock], AlfastrahError>) -> Void) {
        rest.read(
            path: "/api/insurances/help_blocks",
            id: nil,
            parameters: [
                "insurance_id": insuranceId
            ],
            headers: [:],
            responseTransformer: ResponseTransformer(
                key: "help_block_list",
                transformer: ArrayTransformer(
                    transformer: InsuranceProgramHelpBlockTransformer()
                )
            ),
            completion: mapCompletion { result in
                switch result {
                    case .success(let helpBlocks):
                        completion(.success(helpBlocks))
                    case .failure(let error):
                        completion(.failure(error))
                }
            }
        )
    }
}
