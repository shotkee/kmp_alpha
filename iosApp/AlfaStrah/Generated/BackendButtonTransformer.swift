// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct BackendButtonTransformer: Transformer {
    typealias Source = Any
    typealias Destination = BackendButton

    let textHexColorName = "button_text_color"
    let textHexColorThemedName = "button_text_color_themed"
    let backgroundHexColorName = "button_color"
    let backgroundHexColorThemedName = "button_color_themed"
    let actionName = "action"

    let textHexColorTransformer = CastTransformer<Any, String>()
    let textHexColorThemedTransformer = OptionalTransformer(transformer: ThemedValueTransformer())
    let backgroundHexColorTransformer = CastTransformer<Any, String>()
    let backgroundHexColorThemedTransformer = OptionalTransformer(transformer: ThemedValueTransformer())
    let actionTransformer = BackendActionTransformer()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let textHexColorResult = dictionary[textHexColorName].map(textHexColorTransformer.transform(source:)) ?? .failure(.requirement)
        let textHexColorThemedResult = textHexColorThemedTransformer.transform(source: dictionary[textHexColorThemedName])
        let backgroundHexColorResult = dictionary[backgroundHexColorName].map(backgroundHexColorTransformer.transform(source:)) ?? .failure(.requirement)
        let backgroundHexColorThemedResult = backgroundHexColorThemedTransformer.transform(source: dictionary[backgroundHexColorThemedName])
        let actionResult = dictionary[actionName].map(actionTransformer.transform(source:)) ?? .failure(.requirement)

        var errors: [(String, TransformerError)] = []
        textHexColorResult.error.map { errors.append((textHexColorName, $0)) }
        textHexColorThemedResult.error.map { errors.append((textHexColorThemedName, $0)) }
        backgroundHexColorResult.error.map { errors.append((backgroundHexColorName, $0)) }
        backgroundHexColorThemedResult.error.map { errors.append((backgroundHexColorThemedName, $0)) }
        actionResult.error.map { errors.append((actionName, $0)) }

        guard
            let textHexColor = textHexColorResult.value,
            let textHexColorThemed = textHexColorThemedResult.value,
            let backgroundHexColor = backgroundHexColorResult.value,
            let backgroundHexColorThemed = backgroundHexColorThemedResult.value,
            let action = actionResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                textHexColor: textHexColor,
                textHexColorThemed: textHexColorThemed,
                backgroundHexColor: backgroundHexColor,
                backgroundHexColorThemed: backgroundHexColorThemed,
                action: action
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let textHexColorResult = textHexColorTransformer.transform(destination: value.textHexColor)
        let textHexColorThemedResult = textHexColorThemedTransformer.transform(destination: value.textHexColorThemed)
        let backgroundHexColorResult = backgroundHexColorTransformer.transform(destination: value.backgroundHexColor)
        let backgroundHexColorThemedResult = backgroundHexColorThemedTransformer.transform(destination: value.backgroundHexColorThemed)
        let actionResult = actionTransformer.transform(destination: value.action)

        var errors: [(String, TransformerError)] = []
        textHexColorResult.error.map { errors.append((textHexColorName, $0)) }
        textHexColorThemedResult.error.map { errors.append((textHexColorThemedName, $0)) }
        backgroundHexColorResult.error.map { errors.append((backgroundHexColorName, $0)) }
        backgroundHexColorThemedResult.error.map { errors.append((backgroundHexColorThemedName, $0)) }
        actionResult.error.map { errors.append((actionName, $0)) }

        guard
            let textHexColor = textHexColorResult.value,
            let textHexColorThemed = textHexColorThemedResult.value,
            let backgroundHexColor = backgroundHexColorResult.value,
            let backgroundHexColorThemed = backgroundHexColorThemedResult.value,
            let action = actionResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[textHexColorName] = textHexColor
        dictionary[textHexColorThemedName] = textHexColorThemed
        dictionary[backgroundHexColorName] = backgroundHexColor
        dictionary[backgroundHexColorThemedName] = backgroundHexColorThemed
        dictionary[actionName] = action
        return .success(dictionary)
    }
}
