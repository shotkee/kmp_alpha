// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct CascanaSearchResultTransformer: Transformer {
    typealias Source = Any
    typealias Destination = CascanaSearchResult

    let messageIdName = "id"
    let textName = "originalText"
    let highlightedTextName = "highlightText"
    let dateName = "registrationTime"

    let messageIdTransformer = CastTransformer<Any, String>()
    let textTransformer = CastTransformer<Any, String>()
    let highlightedTextTransformer = CastTransformer<Any, String>()
    let dateTransformer = DateTransformer<Any>(format: "yyyy-MM-dd'T'HH:mm:ss.SSSZZZ", locale: AppLocale.currentLocale)

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let messageIdResult = dictionary[messageIdName].map(messageIdTransformer.transform(source:)) ?? .failure(.requirement)
        let textResult = dictionary[textName].map(textTransformer.transform(source:)) ?? .failure(.requirement)
        let highlightedTextResult = dictionary[highlightedTextName].map(highlightedTextTransformer.transform(source:)) ?? .failure(.requirement)
        let dateResult = dictionary[dateName].map(dateTransformer.transform(source:)) ?? .failure(.requirement)

        var errors: [(String, TransformerError)] = []
        messageIdResult.error.map { errors.append((messageIdName, $0)) }
        textResult.error.map { errors.append((textName, $0)) }
        highlightedTextResult.error.map { errors.append((highlightedTextName, $0)) }
        dateResult.error.map { errors.append((dateName, $0)) }

        guard
            let messageId = messageIdResult.value,
            let text = textResult.value,
            let highlightedText = highlightedTextResult.value,
            let date = dateResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                messageId: messageId,
                text: text,
                highlightedText: highlightedText,
                date: date
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let messageIdResult = messageIdTransformer.transform(destination: value.messageId)
        let textResult = textTransformer.transform(destination: value.text)
        let highlightedTextResult = highlightedTextTransformer.transform(destination: value.highlightedText)
        let dateResult = dateTransformer.transform(destination: value.date)

        var errors: [(String, TransformerError)] = []
        messageIdResult.error.map { errors.append((messageIdName, $0)) }
        textResult.error.map { errors.append((textName, $0)) }
        highlightedTextResult.error.map { errors.append((highlightedTextName, $0)) }
        dateResult.error.map { errors.append((dateName, $0)) }

        guard
            let messageId = messageIdResult.value,
            let text = textResult.value,
            let highlightedText = highlightedTextResult.value,
            let date = dateResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[messageIdName] = messageId
        dictionary[textName] = text
        dictionary[highlightedTextName] = highlightedText
        dictionary[dateName] = date
        return .success(dictionary)
    }
}
