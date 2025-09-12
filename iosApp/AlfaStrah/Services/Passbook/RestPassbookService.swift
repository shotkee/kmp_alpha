//
//  RestPassbookService
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 15/01/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import PassKit
import Legacy

class RestPassbookService: PassbookService {
    var isAvailable: Bool {
        PKAddPassesViewController.canAddPasses()
    }
    private let rest: FullRestClient

    init(rest: FullRestClient) {
        self.rest = rest
    }

    func addPass(for insurance: Insurance, completion: @escaping (Result<PKPass, PassbookServiceError>) -> Void) -> NetworkTask {
        rest.read(
            path: "insurances/\(insurance.id)/passbook",
            id: nil,
            parameters: [:],
            headers: [:],
            responseSerializer: DataHttpSerializer(contentType: "")) { result in
                switch result {
                    case .success(let data):
                        do {
                            let pass = try PKPass(data: data)
                            let library = PKPassLibrary()
                            if !library.containsPass(pass) {
                                completion(.success(pass))
                            } else {
                                completion(.failure(.passAlreadyExists))
                            }
                        } catch {
                            completion(.failure(.error(.error(error))))
                        }
                    case .failure(let error):
                        completion(.failure(.error(AlfastrahError.network(error))))
                }
        }
    }
}
