// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct InfoMessageActionTransformer: Transformer {
    typealias Source = Any
    typealias Destination = InfoMessageAction

    let titleTextName = "title"
    let themedBackgroundColorName = "button_color_themed"
    let themedTextColorName = "button_text_color_themed"
    let typeName = "action"

    let titleTextTransformer = OptionalTransformer(transformer: CastTransformer<Any, String>())
    let themedBackgroundColorTransformer = OptionalTransformer(transformer: ThemedValueTransformer())
    let themedTextColorTransformer = OptionalTransformer(transformer: ThemedValueTransformer())
    let typeTransformer = InfoMessageActionTypeTransformer()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let titleTextResult = titleTextTransformer.transform(source: dictionary[titleTextName])
        let themedBackgroundColorResult = themedBackgroundColorTransformer.transform(source: dictionary[themedBackgroundColorName])
        let themedTextColorResult = themedTextColorTransformer.transform(source: dictionary[themedTextColorName])
        let typeResult = dictionary[typeName].map(typeTransformer.transform(source:)) ?? .failure(.requirement)

        var errors: [(String, TransformerError)] = []
        titleTextResult.error.map { errors.append((titleTextName, $0)) }
        themedBackgroundColorResult.error.map { errors.append((themedBackgroundColorName, $0)) }
        themedTextColorResult.error.map { errors.append((themedTextColorName, $0)) }
        typeResult.error.map { errors.append((typeName, $0)) }

        guard
            let titleText = titleTextResult.value,
            let themedBackgroundColor = themedBackgroundColorResult.value,
            let themedTextColor = themedTextColorResult.value,
            let type = typeResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                titleText: titleText,
                themedBackgroundColor: themedBackgroundColor,
                themedTextColor: themedTextColor,
                type: type
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let titleTextResult = titleTextTransformer.transform(destination: value.titleText)
        let themedBackgroundColorResult = themedBackgroundColorTransformer.transform(destination: value.themedBackgroundColor)
        let themedTextColorResult = themedTextColorTransformer.transform(destination: value.themedTextColor)
        let typeResult = typeTransformer.transform(destination: value.type)

        var errors: [(String, TransformerError)] = []
        titleTextResult.error.map { errors.append((titleTextName, $0)) }
        themedBackgroundColorResult.error.map { errors.append((themedBackgroundColorName, $0)) }
        themedTextColorResult.error.map { errors.append((themedTextColorName, $0)) }
        typeResult.error.map { errors.append((typeName, $0)) }

        guard
            let titleText = titleTextResult.value,
            let themedBackgroundColor = themedBackgroundColorResult.value,
            let themedTextColor = themedTextColorResult.value,
            let type = typeResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[titleTextName] = titleText
        dictionary[themedBackgroundColorName] = themedBackgroundColor
        dictionary[themedTextColorName] = themedTextColor
        dictionary[typeName] = type
        return .success(dictionary)
    }
}
