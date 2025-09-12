//
//  PassbookService
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 15/01/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import PassKit
import Legacy

enum PassbookServiceError: Error {
    case passAlreadyExists
    case error(AlfastrahError)
}

protocol PassbookService {
    var isAvailable: Bool { get }

    @discardableResult
    func addPass(for insurance: Insurance, completion: @escaping (Result<PKPass, PassbookServiceError>) -> Void) -> NetworkTask
}
