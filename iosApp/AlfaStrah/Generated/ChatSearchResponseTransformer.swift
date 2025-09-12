// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct ChatSearchResponseTransformer: Transformer {
    typealias Source = Any
    typealias Destination = ChatSearchResponse

    let isDisabledName = "isDisabled"
    let messagesName = "messages"

    let isDisabledTransformer = NumberTransformer<Any, Bool>()
    let messagesTransformer = ArrayTransformer(from: Any.self, transformer: CascanaSearchResultTransformer(), skipFailures: true)

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let isDisabledResult = dictionary[isDisabledName].map(isDisabledTransformer.transform(source:)) ?? .failure(.requirement)
        let messagesResult = dictionary[messagesName].map(messagesTransformer.transform(source:)) ?? .failure(.requirement)

        var errors: [(String, TransformerError)] = []
        isDisabledResult.error.map { errors.append((isDisabledName, $0)) }
        messagesResult.error.map { errors.append((messagesName, $0)) }

        guard
            let isDisabled = isDisabledResult.value,
            let messages = messagesResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                isDisabled: isDisabled,
                messages: messages
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let isDisabledResult = isDisabledTransformer.transform(destination: value.isDisabled)
        let messagesResult = messagesTransformer.transform(destination: value.messages)

        var errors: [(String, TransformerError)] = []
        isDisabledResult.error.map { errors.append((isDisabledName, $0)) }
        messagesResult.error.map { errors.append((messagesName, $0)) }

        guard
            let isDisabled = isDisabledResult.value,
            let messages = messagesResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[isDisabledName] = isDisabled
        dictionary[messagesName] = messages
        return .success(dictionary)
    }
}
