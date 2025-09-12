// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct SignInModelTransformer: Transformer {
    typealias Source = Any
    typealias Destination = SignInModel

    let loginName = "login"
    let passwordName = "password"
    let typeName = "type"
    let isDemoName = "is_demo"
    let deviceTokenName = "device_token"
    let seedName = "seed"
    let hashName = "hash"

    let loginTransformer = CastTransformer<Any, String>()
    let passwordTransformer = CastTransformer<Any, String>()
    let typeTransformer = AccountTypeTransformer()
    let isDemoTransformer = SessionTypeTransformer()
    let deviceTokenTransformer = CastTransformer<Any, String>()
    let seedTransformer = CastTransformer<Any, String>()
    let hashTransformer = CastTransformer<Any, String>()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let loginResult = dictionary[loginName].map(loginTransformer.transform(source:)) ?? .failure(.requirement)
        let passwordResult = dictionary[passwordName].map(passwordTransformer.transform(source:)) ?? .failure(.requirement)
        let typeResult = dictionary[typeName].map(typeTransformer.transform(source:)) ?? .failure(.requirement)
        let isDemoResult = dictionary[isDemoName].map(isDemoTransformer.transform(source:)) ?? .failure(.requirement)
        let deviceTokenResult = dictionary[deviceTokenName].map(deviceTokenTransformer.transform(source:)) ?? .failure(.requirement)
        let seedResult = dictionary[seedName].map(seedTransformer.transform(source:)) ?? .failure(.requirement)
        let hashResult = dictionary[hashName].map(hashTransformer.transform(source:)) ?? .failure(.requirement)

        var errors: [(String, TransformerError)] = []
        loginResult.error.map { errors.append((loginName, $0)) }
        passwordResult.error.map { errors.append((passwordName, $0)) }
        typeResult.error.map { errors.append((typeName, $0)) }
        isDemoResult.error.map { errors.append((isDemoName, $0)) }
        deviceTokenResult.error.map { errors.append((deviceTokenName, $0)) }
        seedResult.error.map { errors.append((seedName, $0)) }
        hashResult.error.map { errors.append((hashName, $0)) }

        guard
            let login = loginResult.value,
            let password = passwordResult.value,
            let type = typeResult.value,
            let isDemo = isDemoResult.value,
            let deviceToken = deviceTokenResult.value,
            let seed = seedResult.value,
            let hash = hashResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                login: login,
                password: password,
                type: type,
                isDemo: isDemo,
                deviceToken: deviceToken,
                seed: seed,
                hash: hash
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let loginResult = loginTransformer.transform(destination: value.login)
        let passwordResult = passwordTransformer.transform(destination: value.password)
        let typeResult = typeTransformer.transform(destination: value.type)
        let isDemoResult = isDemoTransformer.transform(destination: value.isDemo)
        let deviceTokenResult = deviceTokenTransformer.transform(destination: value.deviceToken)
        let seedResult = seedTransformer.transform(destination: value.seed)
        let hashResult = hashTransformer.transform(destination: value.hash)

        var errors: [(String, TransformerError)] = []
        loginResult.error.map { errors.append((loginName, $0)) }
        passwordResult.error.map { errors.append((passwordName, $0)) }
        typeResult.error.map { errors.append((typeName, $0)) }
        isDemoResult.error.map { errors.append((isDemoName, $0)) }
        deviceTokenResult.error.map { errors.append((deviceTokenName, $0)) }
        seedResult.error.map { errors.append((seedName, $0)) }
        hashResult.error.map { errors.append((hashName, $0)) }

        guard
            let login = loginResult.value,
            let password = passwordResult.value,
            let type = typeResult.value,
            let isDemo = isDemoResult.value,
            let deviceToken = deviceTokenResult.value,
            let seed = seedResult.value,
            let hash = hashResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[loginName] = login
        dictionary[passwordName] = password
        dictionary[typeName] = type
        dictionary[isDemoName] = isDemo
        dictionary[deviceTokenName] = deviceToken
        dictionary[seedName] = seed
        dictionary[hashName] = hash
        return .success(dictionary)
    }
}
