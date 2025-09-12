// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct SdkAuthDataTransformer: Transformer {
    typealias Source = Any
    typealias Destination = SdkAuthData

    let secureGuidName = "secure_guid"
    let loginName = "login"
    let passwordName = "password"

    let secureGuidTransformer = CastTransformer<Any, String>()
    let loginTransformer = CastTransformer<Any, String>()
    let passwordTransformer = CastTransformer<Any, String>()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let secureGuidResult = dictionary[secureGuidName].map(secureGuidTransformer.transform(source:)) ?? .failure(.requirement)
        let loginResult = dictionary[loginName].map(loginTransformer.transform(source:)) ?? .failure(.requirement)
        let passwordResult = dictionary[passwordName].map(passwordTransformer.transform(source:)) ?? .failure(.requirement)

        var errors: [(String, TransformerError)] = []
        secureGuidResult.error.map { errors.append((secureGuidName, $0)) }
        loginResult.error.map { errors.append((loginName, $0)) }
        passwordResult.error.map { errors.append((passwordName, $0)) }

        guard
            let secureGuid = secureGuidResult.value,
            let login = loginResult.value,
            let password = passwordResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                secureGuid: secureGuid,
                login: login,
                password: password
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let secureGuidResult = secureGuidTransformer.transform(destination: value.secureGuid)
        let loginResult = loginTransformer.transform(destination: value.login)
        let passwordResult = passwordTransformer.transform(destination: value.password)

        var errors: [(String, TransformerError)] = []
        secureGuidResult.error.map { errors.append((secureGuidName, $0)) }
        loginResult.error.map { errors.append((loginName, $0)) }
        passwordResult.error.map { errors.append((passwordName, $0)) }

        guard
            let secureGuid = secureGuidResult.value,
            let login = loginResult.value,
            let password = passwordResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[secureGuidName] = secureGuid
        dictionary[loginName] = login
        dictionary[passwordName] = password
        return .success(dictionary)
    }
}
