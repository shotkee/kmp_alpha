// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct ClinicLabelListTransformer: Transformer {
    typealias Source = Any
    typealias Destination = ClinicLabelList

    let titleName = "title"
    let colorName = "color"

    let titleTransformer = CastTransformer<Any, String>()
    let colorTransformer = ThemedValueTransformer()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let titleResult = dictionary[titleName].map(titleTransformer.transform(source:)) ?? .failure(.requirement)
        let colorResult = dictionary[colorName].map(colorTransformer.transform(source:)) ?? .failure(.requirement)

        var errors: [(String, TransformerError)] = []
        titleResult.error.map { errors.append((titleName, $0)) }
        colorResult.error.map { errors.append((colorName, $0)) }

        guard
            let title = titleResult.value,
            let color = colorResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                title: title,
                color: color
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let titleResult = titleTransformer.transform(destination: value.title)
        let colorResult = colorTransformer.transform(destination: value.color)

        var errors: [(String, TransformerError)] = []
        titleResult.error.map { errors.append((titleName, $0)) }
        colorResult.error.map { errors.append((colorName, $0)) }

        guard
            let title = titleResult.value,
            let color = colorResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[titleName] = title
        dictionary[colorName] = color
        return .success(dictionary)
    }
}
