// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct ThemedLinkTransformer: Transformer {
    typealias Source = Any
    typealias Destination = ThemedLink

    let urlName = "url"
    let themedTextName = "title"

    let urlTransformer = OptionalTransformer(transformer: UrlTransformer<Any>())
    let themedTextTransformer = OptionalTransformer(transformer: ThemedTextTransformer())

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let urlResult = urlTransformer.transform(source: dictionary[urlName])
        let themedTextResult = themedTextTransformer.transform(source: dictionary[themedTextName])

        var errors: [(String, TransformerError)] = []
        urlResult.error.map { errors.append((urlName, $0)) }
        themedTextResult.error.map { errors.append((themedTextName, $0)) }

        guard
            let url = urlResult.value,
            let themedText = themedTextResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                url: url,
                themedText: themedText
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let urlResult = urlTransformer.transform(destination: value.url)
        let themedTextResult = themedTextTransformer.transform(destination: value.themedText)

        var errors: [(String, TransformerError)] = []
        urlResult.error.map { errors.append((urlName, $0)) }
        themedTextResult.error.map { errors.append((themedTextName, $0)) }

        guard
            let url = urlResult.value,
            let themedText = themedTextResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[urlName] = url
        dictionary[themedTextName] = themedText
        return .success(dictionary)
    }
}
