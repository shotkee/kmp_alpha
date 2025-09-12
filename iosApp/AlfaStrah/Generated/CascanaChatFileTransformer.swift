// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct CascanaChatFileTransformer: Transformer {
    typealias Source = Any
    typealias Destination = CascanaChatFile

    let typeName = "contentType"
    let nameName = "contentName"

    let typeTransformer = CastTransformer<Any, String>()
    let nameTransformer = CastTransformer<Any, String>()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let typeResult = dictionary[typeName].map(typeTransformer.transform(source:)) ?? .failure(.requirement)
        let nameResult = dictionary[nameName].map(nameTransformer.transform(source:)) ?? .failure(.requirement)

        var errors: [(String, TransformerError)] = []
        typeResult.error.map { errors.append((typeName, $0)) }
        nameResult.error.map { errors.append((nameName, $0)) }

        guard
            let type = typeResult.value,
            let name = nameResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                type: type,
                name: name
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let typeResult = typeTransformer.transform(destination: value.type)
        let nameResult = nameTransformer.transform(destination: value.name)

        var errors: [(String, TransformerError)] = []
        typeResult.error.map { errors.append((typeName, $0)) }
        nameResult.error.map { errors.append((nameName, $0)) }

        guard
            let type = typeResult.value,
            let name = nameResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[typeName] = type
        dictionary[nameName] = name
        return .success(dictionary)
    }
}
