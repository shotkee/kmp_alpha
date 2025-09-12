// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct FlatOnOffConfirmActivationResponseTransformer: Transformer {
    typealias Source = Any
    typealias Destination = FlatOnOffConfirmActivationResponse

    let protectionName = "protection"
    let titleName = "title"
    let messageName = "message"

    let protectionTransformer = FlatOnOffProtectionTransformer()
    let titleTransformer = CastTransformer<Any, String>()
    let messageTransformer = CastTransformer<Any, String>()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let protectionResult = dictionary[protectionName].map(protectionTransformer.transform(source:)) ?? .failure(.requirement)
        let titleResult = dictionary[titleName].map(titleTransformer.transform(source:)) ?? .failure(.requirement)
        let messageResult = dictionary[messageName].map(messageTransformer.transform(source:)) ?? .failure(.requirement)

        var errors: [(String, TransformerError)] = []
        protectionResult.error.map { errors.append((protectionName, $0)) }
        titleResult.error.map { errors.append((titleName, $0)) }
        messageResult.error.map { errors.append((messageName, $0)) }

        guard
            let protection = protectionResult.value,
            let title = titleResult.value,
            let message = messageResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                protection: protection,
                title: title,
                message: message
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let protectionResult = protectionTransformer.transform(destination: value.protection)
        let titleResult = titleTransformer.transform(destination: value.title)
        let messageResult = messageTransformer.transform(destination: value.message)

        var errors: [(String, TransformerError)] = []
        protectionResult.error.map { errors.append((protectionName, $0)) }
        titleResult.error.map { errors.append((titleName, $0)) }
        messageResult.error.map { errors.append((messageName, $0)) }

        guard
            let protection = protectionResult.value,
            let title = titleResult.value,
            let message = messageResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[protectionName] = protection
        dictionary[titleName] = title
        dictionary[messageName] = message
        return .success(dictionary)
    }
}
