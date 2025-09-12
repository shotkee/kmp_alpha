//
//  RestPhoneCallsService
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 20/05/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import Legacy

class RestPhoneCallsService: PhoneCallsService {
    private let rest: FullRestClient

    init(rest: FullRestClient) {
        self.rest = rest
    }

    func requestCallback(_ callback: Callback, completion: @escaping (Result<CallbackResponse, AlfastrahError>) -> Void) {
        rest.create(
            path: "/phone_calls/request_callback",
            id: nil,
            object: callback,
            headers: [:],
            requestTransformer: CallbackTransformer(),
            responseTransformer: ResponseTransformer(transformer: CallbackResponseTransformer()),
            completion: mapCompletion(completion)
        )
    }

    func phoneListFromCallCenter(completion: @escaping (Result<[Phone], AlfastrahError>) -> Void) {
        rest.read(
            path: "/phone_calls/call_center",
            id: nil,
            parameters: [:],
            headers: [:],
            responseTransformer: ResponseTransformer(
                key: "phones",
                transformer: ArrayTransformer(transformer: PhoneTransformer())
            ),
            completion: mapCompletion(completion)
        )
    }
}
