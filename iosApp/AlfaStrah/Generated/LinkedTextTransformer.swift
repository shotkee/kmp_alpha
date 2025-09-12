// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct LinkedTextTransformer: Transformer {
    typealias Source = Any
    typealias Destination = LinkedText

    let textName = "text"
    let linksName = "links"

    let textTransformer = CastTransformer<Any, String>()
    let linksTransformer = ArrayTransformer(from: Any.self, transformer: LinkTransformer(), skipFailures: true)

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let textResult = dictionary[textName].map(textTransformer.transform(source:)) ?? .failure(.requirement)
        let linksResult = dictionary[linksName].map(linksTransformer.transform(source:)) ?? .failure(.requirement)

        var errors: [(String, TransformerError)] = []
        textResult.error.map { errors.append((textName, $0)) }
        linksResult.error.map { errors.append((linksName, $0)) }

        guard
            let text = textResult.value,
            let links = linksResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                text: text,
                links: links
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let textResult = textTransformer.transform(destination: value.text)
        let linksResult = linksTransformer.transform(destination: value.links)

        var errors: [(String, TransformerError)] = []
        textResult.error.map { errors.append((textName, $0)) }
        linksResult.error.map { errors.append((linksName, $0)) }

        guard
            let text = textResult.value,
            let links = linksResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[textName] = text
        dictionary[linksName] = links
        return .success(dictionary)
    }
}
