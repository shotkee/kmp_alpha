// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct OsagoProlongationEditedFieldTransformer: Transformer {
    typealias Source = Any
    typealias Destination = OsagoProlongationEditedField

    let idName = "id"
    let dataName = "data"

    let idTransformer = CastTransformer<Any, String>()
    let dataTransformer = OsagoProlongationFieldDataTransformer()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let idResult = dictionary[idName].map(idTransformer.transform(source:)) ?? .failure(.requirement)
        let dataResult = dictionary[dataName].map(dataTransformer.transform(source:)) ?? .failure(.requirement)

        var errors: [(String, TransformerError)] = []
        idResult.error.map { errors.append((idName, $0)) }
        dataResult.error.map { errors.append((dataName, $0)) }

        guard
            let id = idResult.value,
            let data = dataResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                id: id,
                data: data
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let idResult = idTransformer.transform(destination: value.id)
        let dataResult = dataTransformer.transform(destination: value.data)

        var errors: [(String, TransformerError)] = []
        idResult.error.map { errors.append((idName, $0)) }
        dataResult.error.map { errors.append((dataName, $0)) }

        guard
            let id = idResult.value,
            let data = dataResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[idName] = id
        dictionary[dataName] = data
        return .success(dictionary)
    }
}
