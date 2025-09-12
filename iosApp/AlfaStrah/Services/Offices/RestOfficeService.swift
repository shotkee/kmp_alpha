//
//  RestOfficeService
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 03/12/2018.
//  Copyright © 2018 Redmadrobot. All rights reserved.
//

import Legacy

class RestOfficeService: OfficesService {
    private let rest: FullRestClient

    init(rest: FullRestClient) {
        self.rest = rest
    }

    func offices(completion: @escaping (Result<[Office], AlfastrahError>) -> Void) {
        rest.read(
            path: "offices",
            id: nil,
            parameters: [:],
            headers: [:],
            responseTransformer: ResponseTransformer(
                key: "office_list",
                transformer: ArrayTransformer(transformer: OfficeTransformer())
            ),
            completion: mapCompletion(completion)
        )
    }

    func cities(completion: @escaping (Result<[City], AlfastrahError>) -> Void) {
        rest.read(
            path: "cities",
            id: nil,
            parameters: ["collection": "offices"],
            headers: [:],
            responseTransformer: ResponseTransformer(
                key: "city_list",
                transformer: ArrayTransformer(transformer: CityTransformer())
            ),
            completion: mapCompletion(completion)
        )
    }
}
