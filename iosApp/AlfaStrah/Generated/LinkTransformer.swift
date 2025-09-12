// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct LinkTransformer: Transformer {
    typealias Source = Any
    typealias Destination = Link

    let textName = "text"
    let pathName = "link"

    let textTransformer = CastTransformer<Any, String>()
    let pathTransformer = CastTransformer<Any, String>()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let textResult = dictionary[textName].map(textTransformer.transform(source:)) ?? .failure(.requirement)
        let pathResult = dictionary[pathName].map(pathTransformer.transform(source:)) ?? .failure(.requirement)

        var errors: [(String, TransformerError)] = []
        textResult.error.map { errors.append((textName, $0)) }
        pathResult.error.map { errors.append((pathName, $0)) }

        guard
            let text = textResult.value,
            let path = pathResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                text: text,
                path: path
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let textResult = textTransformer.transform(destination: value.text)
        let pathResult = pathTransformer.transform(destination: value.path)

        var errors: [(String, TransformerError)] = []
        textResult.error.map { errors.append((textName, $0)) }
        pathResult.error.map { errors.append((pathName, $0)) }

        guard
            let text = textResult.value,
            let path = pathResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[textName] = text
        dictionary[pathName] = path
        return .success(dictionary)
    }
}
