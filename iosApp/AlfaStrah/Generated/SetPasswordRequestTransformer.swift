// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct SetPasswordRequestTransformer: Transformer {
    typealias Source = Any
    typealias Destination = SetPasswordRequest

    let oldPasswordName = "old_password"
    let passwordName = "password"

    let oldPasswordTransformer = CastTransformer<Any, String>()
    let passwordTransformer = CastTransformer<Any, String>()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let oldPasswordResult = dictionary[oldPasswordName].map(oldPasswordTransformer.transform(source:)) ?? .failure(.requirement)
        let passwordResult = dictionary[passwordName].map(passwordTransformer.transform(source:)) ?? .failure(.requirement)

        var errors: [(String, TransformerError)] = []
        oldPasswordResult.error.map { errors.append((oldPasswordName, $0)) }
        passwordResult.error.map { errors.append((passwordName, $0)) }

        guard
            let oldPassword = oldPasswordResult.value,
            let password = passwordResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                oldPassword: oldPassword,
                password: password
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let oldPasswordResult = oldPasswordTransformer.transform(destination: value.oldPassword)
        let passwordResult = passwordTransformer.transform(destination: value.password)

        var errors: [(String, TransformerError)] = []
        oldPasswordResult.error.map { errors.append((oldPasswordName, $0)) }
        passwordResult.error.map { errors.append((passwordName, $0)) }

        guard
            let oldPassword = oldPasswordResult.value,
            let password = passwordResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[oldPasswordName] = oldPassword
        dictionary[passwordName] = password
        return .success(dictionary)
    }
}
