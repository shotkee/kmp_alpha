// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct CascanaChatChildThemeTransformer: Transformer {
    typealias Source = Any
    typealias Destination = CascanaChatChildTheme

    let idName = "id"
    let nameName = "name"
    let childrenName = "children"

    let idTransformer = CastTransformer<Any, String>()
    let nameTransformer = CastTransformer<Any, String>()
    let childrenTransformer = ArrayTransformer(from: Any.self, transformer: CastTransformer<Any, String>(), skipFailures: true)

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let idResult = dictionary[idName].map(idTransformer.transform(source:)) ?? .failure(.requirement)
        let nameResult = dictionary[nameName].map(nameTransformer.transform(source:)) ?? .failure(.requirement)
        let childrenResult = dictionary[childrenName].map(childrenTransformer.transform(source:)) ?? .failure(.requirement)

        var errors: [(String, TransformerError)] = []
        idResult.error.map { errors.append((idName, $0)) }
        nameResult.error.map { errors.append((nameName, $0)) }
        childrenResult.error.map { errors.append((childrenName, $0)) }

        guard
            let id = idResult.value,
            let name = nameResult.value,
            let children = childrenResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                id: id,
                name: name,
                children: children
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let idResult = idTransformer.transform(destination: value.id)
        let nameResult = nameTransformer.transform(destination: value.name)
        let childrenResult = childrenTransformer.transform(destination: value.children)

        var errors: [(String, TransformerError)] = []
        idResult.error.map { errors.append((idName, $0)) }
        nameResult.error.map { errors.append((nameName, $0)) }
        childrenResult.error.map { errors.append((childrenName, $0)) }

        guard
            let id = idResult.value,
            let name = nameResult.value,
            let children = childrenResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[idName] = id
        dictionary[nameName] = name
        dictionary[childrenName] = children
        return .success(dictionary)
    }
}
