// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct OsagoProlongationDeeplinkTransformer: Transformer {
    typealias Source = Any
    typealias Destination = OsagoProlongationDeeplink

    let urlName = "url"

    let urlTransformer = UrlTransformer<Any>()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let urlResult = dictionary[urlName].map(urlTransformer.transform(source:)) ?? .failure(.requirement)

        var errors: [(String, TransformerError)] = []
        urlResult.error.map { errors.append((urlName, $0)) }

        guard
            let url = urlResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                url: url
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let urlResult = urlTransformer.transform(destination: value.url)

        var errors: [(String, TransformerError)] = []
        urlResult.error.map { errors.append((urlName, $0)) }

        guard
            let url = urlResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[urlName] = url
        return .success(dictionary)
    }
}
