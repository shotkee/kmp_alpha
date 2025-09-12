// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct CheckPartnerCodesResponseTransformer: Transformer {
    typealias Source = Any
    typealias Destination = CheckPartnerCodesResponse

    let passwordName = "password"

    let passwordTransformer = CastTransformer<Any, String>()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let passwordResult = dictionary[passwordName].map(passwordTransformer.transform(source:)) ?? .failure(.requirement)

        var errors: [(String, TransformerError)] = []
        passwordResult.error.map { errors.append((passwordName, $0)) }

        guard
            let password = passwordResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                password: password
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let passwordResult = passwordTransformer.transform(destination: value.password)

        var errors: [(String, TransformerError)] = []
        passwordResult.error.map { errors.append((passwordName, $0)) }

        guard
            let password = passwordResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[passwordName] = password
        return .success(dictionary)
    }
}
