// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct InsuranceProductTagTransformer: Transformer {
    typealias Source = Any
    typealias Destination = InsuranceProductTag

    let titleName = "title"
    let titleColorName = "title_color"
    let titleColorThemedName = "title_color_themed"
    let backgroundColorName = "background_color"
    let backgroundColorThemedName = "background_color_themed"

    let titleTransformer = CastTransformer<Any, String>()
    let titleColorTransformer = CastTransformer<Any, String>()
    let titleColorThemedTransformer = OptionalTransformer(transformer: ThemedValueTransformer())
    let backgroundColorTransformer = CastTransformer<Any, String>()
    let backgroundColorThemedTransformer = OptionalTransformer(transformer: ThemedValueTransformer())

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let titleResult = dictionary[titleName].map(titleTransformer.transform(source:)) ?? .failure(.requirement)
        let titleColorResult = dictionary[titleColorName].map(titleColorTransformer.transform(source:)) ?? .failure(.requirement)
        let titleColorThemedResult = titleColorThemedTransformer.transform(source: dictionary[titleColorThemedName])
        let backgroundColorResult = dictionary[backgroundColorName].map(backgroundColorTransformer.transform(source:)) ?? .failure(.requirement)
        let backgroundColorThemedResult = backgroundColorThemedTransformer.transform(source: dictionary[backgroundColorThemedName])

        var errors: [(String, TransformerError)] = []
        titleResult.error.map { errors.append((titleName, $0)) }
        titleColorResult.error.map { errors.append((titleColorName, $0)) }
        titleColorThemedResult.error.map { errors.append((titleColorThemedName, $0)) }
        backgroundColorResult.error.map { errors.append((backgroundColorName, $0)) }
        backgroundColorThemedResult.error.map { errors.append((backgroundColorThemedName, $0)) }

        guard
            let title = titleResult.value,
            let titleColor = titleColorResult.value,
            let titleColorThemed = titleColorThemedResult.value,
            let backgroundColor = backgroundColorResult.value,
            let backgroundColorThemed = backgroundColorThemedResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                title: title,
                titleColor: titleColor,
                titleColorThemed: titleColorThemed,
                backgroundColor: backgroundColor,
                backgroundColorThemed: backgroundColorThemed
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let titleResult = titleTransformer.transform(destination: value.title)
        let titleColorResult = titleColorTransformer.transform(destination: value.titleColor)
        let titleColorThemedResult = titleColorThemedTransformer.transform(destination: value.titleColorThemed)
        let backgroundColorResult = backgroundColorTransformer.transform(destination: value.backgroundColor)
        let backgroundColorThemedResult = backgroundColorThemedTransformer.transform(destination: value.backgroundColorThemed)

        var errors: [(String, TransformerError)] = []
        titleResult.error.map { errors.append((titleName, $0)) }
        titleColorResult.error.map { errors.append((titleColorName, $0)) }
        titleColorThemedResult.error.map { errors.append((titleColorThemedName, $0)) }
        backgroundColorResult.error.map { errors.append((backgroundColorName, $0)) }
        backgroundColorThemedResult.error.map { errors.append((backgroundColorThemedName, $0)) }

        guard
            let title = titleResult.value,
            let titleColor = titleColorResult.value,
            let titleColorThemed = titleColorThemedResult.value,
            let backgroundColor = backgroundColorResult.value,
            let backgroundColorThemed = backgroundColorThemedResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[titleName] = title
        dictionary[titleColorName] = titleColor
        dictionary[titleColorThemedName] = titleColorThemed
        dictionary[backgroundColorName] = backgroundColor
        dictionary[backgroundColorThemedName] = backgroundColorThemed
        return .success(dictionary)
    }
}
