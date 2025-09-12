// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct ThemedButtonTransformer: Transformer {
    typealias Source = Any
    typealias Destination = ThemedButton

    let themedTextColorName = "button_text_color_themed"
    let themedBackgroundColorName = "button_color_themed"
    let themedBorderColorName = "border"
    let actionName = "action"

    let themedTextColorTransformer = OptionalTransformer(transformer: ThemedValueTransformer())
    let themedBackgroundColorTransformer = OptionalTransformer(transformer: ThemedValueTransformer())
    let themedBorderColorTransformer = OptionalTransformer(transformer: ThemedValueTransformer())
    let actionTransformer = OptionalTransformer(transformer: BackendActionTransformer())

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let themedTextColorResult = themedTextColorTransformer.transform(source: dictionary[themedTextColorName])
        let themedBackgroundColorResult = themedBackgroundColorTransformer.transform(source: dictionary[themedBackgroundColorName])
        let themedBorderColorResult = themedBorderColorTransformer.transform(source: dictionary[themedBorderColorName])
        let actionResult = actionTransformer.transform(source: dictionary[actionName])

        var errors: [(String, TransformerError)] = []
        themedTextColorResult.error.map { errors.append((themedTextColorName, $0)) }
        themedBackgroundColorResult.error.map { errors.append((themedBackgroundColorName, $0)) }
        themedBorderColorResult.error.map { errors.append((themedBorderColorName, $0)) }
        actionResult.error.map { errors.append((actionName, $0)) }

        guard
            let themedTextColor = themedTextColorResult.value,
            let themedBackgroundColor = themedBackgroundColorResult.value,
            let themedBorderColor = themedBorderColorResult.value,
            let action = actionResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                themedTextColor: themedTextColor,
                themedBackgroundColor: themedBackgroundColor,
                themedBorderColor: themedBorderColor,
                action: action
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let themedTextColorResult = themedTextColorTransformer.transform(destination: value.themedTextColor)
        let themedBackgroundColorResult = themedBackgroundColorTransformer.transform(destination: value.themedBackgroundColor)
        let themedBorderColorResult = themedBorderColorTransformer.transform(destination: value.themedBorderColor)
        let actionResult = actionTransformer.transform(destination: value.action)

        var errors: [(String, TransformerError)] = []
        themedTextColorResult.error.map { errors.append((themedTextColorName, $0)) }
        themedBackgroundColorResult.error.map { errors.append((themedBackgroundColorName, $0)) }
        themedBorderColorResult.error.map { errors.append((themedBorderColorName, $0)) }
        actionResult.error.map { errors.append((actionName, $0)) }

        guard
            let themedTextColor = themedTextColorResult.value,
            let themedBackgroundColor = themedBackgroundColorResult.value,
            let themedBorderColor = themedBorderColorResult.value,
            let action = actionResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[themedTextColorName] = themedTextColor
        dictionary[themedBackgroundColorName] = themedBackgroundColor
        dictionary[themedBorderColorName] = themedBorderColor
        dictionary[actionName] = action
        return .success(dictionary)
    }
}
