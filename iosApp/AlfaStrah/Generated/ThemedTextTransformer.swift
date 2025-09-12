// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct ThemedTextTransformer: Transformer {
    typealias Source = Any
    typealias Destination = ThemedText

    let textName = "text"
    let themedColorName = "color"

    let textTransformer = CastTransformer<Any, String>()
    let themedColorTransformer = OptionalTransformer(transformer: ThemedValueTransformer())

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let textResult = dictionary[textName].map(textTransformer.transform(source:)) ?? .failure(.requirement)
        let themedColorResult = themedColorTransformer.transform(source: dictionary[themedColorName])

        var errors: [(String, TransformerError)] = []
        textResult.error.map { errors.append((textName, $0)) }
        themedColorResult.error.map { errors.append((themedColorName, $0)) }

        guard
            let text = textResult.value,
            let themedColor = themedColorResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                text: text,
                themedColor: themedColor
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let textResult = textTransformer.transform(destination: value.text)
        let themedColorResult = themedColorTransformer.transform(destination: value.themedColor)

        var errors: [(String, TransformerError)] = []
        textResult.error.map { errors.append((textName, $0)) }
        themedColorResult.error.map { errors.append((themedColorName, $0)) }

        guard
            let text = textResult.value,
            let themedColor = themedColorResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[textName] = text
        dictionary[themedColorName] = themedColor
        return .success(dictionary)
    }
}
