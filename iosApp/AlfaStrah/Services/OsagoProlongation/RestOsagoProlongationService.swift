//
//  RestOsagoProlongationService.swift
//  AlfaStrah
//
//  Created by Nikita Omelchenko on 19.02.2021.
//  Copyright © 2021 Redmadrobot. All rights reserved.
//

import Legacy

// swiftlint:disable file_length

class RestOsagoProlongationService: OsagoProlongationService {
    private let rest: FullRestClient

    init(rest: FullRestClient) {
        self.rest = rest
    }

    func insurancesOsagoProlongationCalcRequest(
        insuranceId: String,
        completion: @escaping (Result<OsagoProlongation, AlfastrahError>) -> Void
    ) -> NetworkTask {
        rest.create(
            path: "api/insurances/osago/prolongation/calc",
            id: nil,
            object: [ "insurance_id": "\(insuranceId)" ],
            headers: [:],
            requestTransformer: DictionaryTransformer(
                keyTransformer: CastTransformer<AnyHashable, String>(),
                valueTransformer: CastTransformer<Any, String>()
            ),
            responseTransformer: ResponseTransformer(transformer: OsagoProlongationTransformer()),
            completion: mapCompletion(completion)
        )
    }

    func insurancesOsagoProlongationChangeRequest(
        changeRequest: OsagoProlongationChangeRequest,
        completion: @escaping (Result<Void, AlfastrahError>) -> Void
    ) {
        rest.create(
            path: "api/insurances/osago/prolongation/change",
            id: nil,
            object: changeRequest,
            headers: [:],
            requestTransformer: OsagoProlongationChangeRequestTransformer(),
            responseTransformer: VoidTransformer(),
            completion: mapCompletion(completion)
        )
    }

    func insurancesOsagoProlongationDeeplinkRequest(
        insuranceId: String,
        agreedToPersonalDataPolicy: Bool,
        completion: @escaping (Result<OsagoProlongationDeeplink, AlfastrahError>) -> Void
    ) {
        rest.create(
            path: "api/insurances/osago/prolongation/deeplink",
            id: nil,
            object: OsagoProlongationDeeplinkRequest(
                insuranceId: insuranceId,
                agreedToPersonalDataPolicy: agreedToPersonalDataPolicy
            ),
            headers: [:],
            requestTransformer: OsagoProlongationDeeplinkRequestTransformer(),
            responseTransformer: ResponseTransformer(transformer: OsagoProlongationDeeplinkTransformer()),
            completion: mapCompletion(completion)
        )
    }

    func insurancesOsagoProlongationProgramRequest(
        insuranceID: String,
        completion: @escaping (Result<OsagoProlongationURLs, AlfastrahError>) -> Void
    ) -> NetworkTask {
        rest.read(
            path: "api/insurances/osago/prolongation/program",
            id: nil,
            parameters: [ "insurance_id": "\(insuranceID)" ],
            headers: [:],
            responseTransformer: ResponseTransformer(transformer: OsagoProlongationURLsTransformer()),
            completion: mapCompletion(completion)
        )
    }
}
