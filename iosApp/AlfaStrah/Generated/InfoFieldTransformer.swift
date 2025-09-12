// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct InfoFieldTransformer: Transformer {
    typealias Source = Any
    typealias Destination = InfoField

    let typeName = "type"
    let titleName = "title"
    let textName = "text"
    let coordinateName = "coordinate"

    let typeTransformer = InfoFieldKindTransformer()
    let titleTransformer = CastTransformer<Any, String>()
    let textTransformer = CastTransformer<Any, String>()
    let coordinateTransformer = OptionalTransformer(transformer: CoordinateTransformer())

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let typeResult = dictionary[typeName].map(typeTransformer.transform(source:)) ?? .failure(.requirement)
        let titleResult = dictionary[titleName].map(titleTransformer.transform(source:)) ?? .failure(.requirement)
        let textResult = dictionary[textName].map(textTransformer.transform(source:)) ?? .failure(.requirement)
        let coordinateResult = coordinateTransformer.transform(source: dictionary[coordinateName])

        var errors: [(String, TransformerError)] = []
        typeResult.error.map { errors.append((typeName, $0)) }
        titleResult.error.map { errors.append((titleName, $0)) }
        textResult.error.map { errors.append((textName, $0)) }
        coordinateResult.error.map { errors.append((coordinateName, $0)) }

        guard
            let type = typeResult.value,
            let title = titleResult.value,
            let text = textResult.value,
            let coordinate = coordinateResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                type: type,
                title: title,
                text: text,
                coordinate: coordinate
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let typeResult = typeTransformer.transform(destination: value.type)
        let titleResult = titleTransformer.transform(destination: value.title)
        let textResult = textTransformer.transform(destination: value.text)
        let coordinateResult = coordinateTransformer.transform(destination: value.coordinate)

        var errors: [(String, TransformerError)] = []
        typeResult.error.map { errors.append((typeName, $0)) }
        titleResult.error.map { errors.append((titleName, $0)) }
        textResult.error.map { errors.append((textName, $0)) }
        coordinateResult.error.map { errors.append((coordinateName, $0)) }

        guard
            let type = typeResult.value,
            let title = titleResult.value,
            let text = textResult.value,
            let coordinate = coordinateResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[typeName] = type
        dictionary[titleName] = title
        dictionary[textName] = text
        dictionary[coordinateName] = coordinate
        return .success(dictionary)
    }
}
