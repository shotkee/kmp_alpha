// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct InsuranceActivateResponseTransformer: Transformer {
    typealias Source = Any
    typealias Destination = InsuranceActivateResponse

    let successName = "success"
    let messageName = "message"

    let successTransformer = NumberTransformer<Any, Bool>()
    let messageTransformer = OptionalTransformer(transformer: CastTransformer<Any, String>())

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let successResult = dictionary[successName].map(successTransformer.transform(source:)) ?? .failure(.requirement)
        let messageResult = messageTransformer.transform(source: dictionary[messageName])

        var errors: [(String, TransformerError)] = []
        successResult.error.map { errors.append((successName, $0)) }
        messageResult.error.map { errors.append((messageName, $0)) }

        guard
            let success = successResult.value,
            let message = messageResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                success: success,
                message: message
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let successResult = successTransformer.transform(destination: value.success)
        let messageResult = messageTransformer.transform(destination: value.message)

        var errors: [(String, TransformerError)] = []
        successResult.error.map { errors.append((successName, $0)) }
        messageResult.error.map { errors.append((messageName, $0)) }

        guard
            let success = successResult.value,
            let message = messageResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[successName] = success
        dictionary[messageName] = message
        return .success(dictionary)
    }
}
