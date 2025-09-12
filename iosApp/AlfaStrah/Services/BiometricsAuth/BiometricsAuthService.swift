//
//  BiometricsAuthService
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 26/10/2018.
//  Copyright © 2018 RedMadRobot. All rights reserved.
//

import Legacy

enum BiometryType {
    case none
    case touchID
    case faceID
}

enum BiometricsAuthError: Error {
    case unknown
    case notAvailable
    case failed
    case cancelled
    case fallback
    case notEnrolled
    case error(Error)
}

protocol BiometricsAuthService {
    var available: Bool { get }
    var type: BiometryType { get }
    func authenticate(reason: String, completion: @escaping (Result<Void, BiometricsAuthError>) -> Void)
}
