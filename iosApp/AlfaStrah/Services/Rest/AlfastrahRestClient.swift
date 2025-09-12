//
//  AlfastrahRestClient
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 11.12.2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import Foundation
import Legacy

class AlfastrahRestClient: BaseRestClient {
    override func request<RequestSerializer: HttpSerializer, ResponseSerializer: HttpSerializer>(
        method: HttpMethod, path: String,
        parameters: [String: String], object: RequestSerializer.Value?, headers: [String: String],
        requestSerializer: RequestSerializer, responseSerializer: ResponseSerializer,
        completion: @escaping (Result<ResponseSerializer.Value, NetworkError>) -> Void
    ) -> NetworkTask {
        withBackgroundTask { (endTask: @escaping () -> Void) -> NetworkTask in
			let headersWithDefaultHeaders =
				UserAgent.headers
					.merging(headers) { _, new in new }
					.merging(UserAgent.themeHeader()) { _, new in new }
			
            return super.request(
                method: method,
                path: path,
                parameters: parameters,
                object: object,
                headers: headersWithDefaultHeaders,
                requestSerializer: requestSerializer,
                responseSerializer: responseSerializer
            ) { result in
                completion(result)
                endTask()
            }
        }
    }
}
