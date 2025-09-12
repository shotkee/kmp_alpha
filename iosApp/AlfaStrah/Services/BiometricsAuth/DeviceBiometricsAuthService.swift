//
//  DeviceBiometricsAuthService.swift
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 26/10/2018.
//  Copyright © 2018 RedMadRobot. All rights reserved.
//

import Foundation
import LocalAuthentication
import Legacy

@objc final class DeviceBiometricsAuthService: NSObject, BiometricsAuthService {
    private let context = LAContext()

    var type: BiometryType {
        _ = available
        switch context.biometryType {
            case .none:
                return .none
            case .touchID:
                return .touchID
            case .faceID:
                return .faceID
            @unknown default:
                return .none
        }
    }

    @objc var isFaceID: Bool {
        type == .faceID
    }

    @objc var available: Bool {
        context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
    }

    func authenticate(reason: String, completion: @escaping (Result<Void, BiometricsAuthError>) -> Void) {
        guard available else { return completion(.failure(.notAvailable)) }

        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, error in
            DispatchQueue.main.async {
                if success {
                    completion(.success(()))
                } else if let error = error as? LAError {
                    switch error.code {
                        case LAError.authenticationFailed:
                            completion(.failure(.failed))
                        case LAError.userCancel:
                            completion(.failure(.cancelled))
                        case LAError.userFallback:
                            completion(.failure(.fallback))
                        case LAError.biometryNotEnrolled:
                            completion(.failure(.notEnrolled))
                        default:
                            completion(.failure(.error(error)))
                    }
                } else {
                    completion(.failure(.unknown))
                }
            }
        }
    }
}
