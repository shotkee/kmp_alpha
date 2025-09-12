// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct InsuranceProductDetailedButtonTransformer: Transformer {
    typealias Source = Any
    typealias Destination = InsuranceProductDetailedButton

    let textColorName = "button_text_color"
    let textColorThemedName = "button_text_color_themed"
    let buttonColorName = "button_color"
    let buttonColorThemedName = "button_color_themed"
    let actionName = "action"

    let textColorTransformer = CastTransformer<Any, String>()
    let textColorThemedTransformer = OptionalTransformer(transformer: ThemedValueTransformer())
    let buttonColorTransformer = CastTransformer<Any, String>()
    let buttonColorThemedTransformer = OptionalTransformer(transformer: ThemedValueTransformer())
    let actionTransformer = BackendActionTransformer()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let textColorResult = dictionary[textColorName].map(textColorTransformer.transform(source:)) ?? .failure(.requirement)
        let textColorThemedResult = textColorThemedTransformer.transform(source: dictionary[textColorThemedName])
        let buttonColorResult = dictionary[buttonColorName].map(buttonColorTransformer.transform(source:)) ?? .failure(.requirement)
        let buttonColorThemedResult = buttonColorThemedTransformer.transform(source: dictionary[buttonColorThemedName])
        let actionResult = dictionary[actionName].map(actionTransformer.transform(source:)) ?? .failure(.requirement)

        var errors: [(String, TransformerError)] = []
        textColorResult.error.map { errors.append((textColorName, $0)) }
        textColorThemedResult.error.map { errors.append((textColorThemedName, $0)) }
        buttonColorResult.error.map { errors.append((buttonColorName, $0)) }
        buttonColorThemedResult.error.map { errors.append((buttonColorThemedName, $0)) }
        actionResult.error.map { errors.append((actionName, $0)) }

        guard
            let textColor = textColorResult.value,
            let textColorThemed = textColorThemedResult.value,
            let buttonColor = buttonColorResult.value,
            let buttonColorThemed = buttonColorThemedResult.value,
            let action = actionResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                textColor: textColor,
                textColorThemed: textColorThemed,
                buttonColor: buttonColor,
                buttonColorThemed: buttonColorThemed,
                action: action
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let textColorResult = textColorTransformer.transform(destination: value.textColor)
        let textColorThemedResult = textColorThemedTransformer.transform(destination: value.textColorThemed)
        let buttonColorResult = buttonColorTransformer.transform(destination: value.buttonColor)
        let buttonColorThemedResult = buttonColorThemedTransformer.transform(destination: value.buttonColorThemed)
        let actionResult = actionTransformer.transform(destination: value.action)

        var errors: [(String, TransformerError)] = []
        textColorResult.error.map { errors.append((textColorName, $0)) }
        textColorThemedResult.error.map { errors.append((textColorThemedName, $0)) }
        buttonColorResult.error.map { errors.append((buttonColorName, $0)) }
        buttonColorThemedResult.error.map { errors.append((buttonColorThemedName, $0)) }
        actionResult.error.map { errors.append((actionName, $0)) }

        guard
            let textColor = textColorResult.value,
            let textColorThemed = textColorThemedResult.value,
            let buttonColor = buttonColorResult.value,
            let buttonColorThemed = buttonColorThemedResult.value,
            let action = actionResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[textColorName] = textColor
        dictionary[textColorThemedName] = textColorThemed
        dictionary[buttonColorName] = buttonColor
        dictionary[buttonColorThemedName] = buttonColorThemed
        dictionary[actionName] = action
        return .success(dictionary)
    }
}
