// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct ClinicMetroTransformer: Transformer {
    typealias Source = Any
    typealias Destination = ClinicMetro

    let idName = "id"
    let titleName = "title"
    let colorName = "color"

    let idTransformer = NumberTransformer<Any, Int>()
    let titleTransformer = CastTransformer<Any, String>()
    let colorTransformer = ThemedValueTransformer()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let idResult = dictionary[idName].map(idTransformer.transform(source:)) ?? .failure(.requirement)
        let titleResult = dictionary[titleName].map(titleTransformer.transform(source:)) ?? .failure(.requirement)
        let colorResult = dictionary[colorName].map(colorTransformer.transform(source:)) ?? .failure(.requirement)

        var errors: [(String, TransformerError)] = []
        idResult.error.map { errors.append((idName, $0)) }
        titleResult.error.map { errors.append((titleName, $0)) }
        colorResult.error.map { errors.append((colorName, $0)) }

        guard
            let id = idResult.value,
            let title = titleResult.value,
            let color = colorResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                id: id,
                title: title,
                color: color
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let idResult = idTransformer.transform(destination: value.id)
        let titleResult = titleTransformer.transform(destination: value.title)
        let colorResult = colorTransformer.transform(destination: value.color)

        var errors: [(String, TransformerError)] = []
        idResult.error.map { errors.append((idName, $0)) }
        titleResult.error.map { errors.append((titleName, $0)) }
        colorResult.error.map { errors.append((colorName, $0)) }

        guard
            let id = idResult.value,
            let title = titleResult.value,
            let color = colorResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[idName] = id
        dictionary[titleName] = title
        dictionary[colorName] = color
        return .success(dictionary)
    }
}
