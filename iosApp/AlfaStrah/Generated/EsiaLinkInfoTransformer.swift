// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct EsiaLinkInfoTransformer: Transformer {
    typealias Source = Any
    typealias Destination = EsiaLinkInfo

    let esiaUrlName = "esia_url"
    let redirectUrlName = "redirect_url"

    let esiaUrlTransformer = UrlTransformer<Any>()
    let redirectUrlTransformer = UrlTransformer<Any>()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let esiaUrlResult = dictionary[esiaUrlName].map(esiaUrlTransformer.transform(source:)) ?? .failure(.requirement)
        let redirectUrlResult = dictionary[redirectUrlName].map(redirectUrlTransformer.transform(source:)) ?? .failure(.requirement)

        var errors: [(String, TransformerError)] = []
        esiaUrlResult.error.map { errors.append((esiaUrlName, $0)) }
        redirectUrlResult.error.map { errors.append((redirectUrlName, $0)) }

        guard
            let esiaUrl = esiaUrlResult.value,
            let redirectUrl = redirectUrlResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                esiaUrl: esiaUrl,
                redirectUrl: redirectUrl
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let esiaUrlResult = esiaUrlTransformer.transform(destination: value.esiaUrl)
        let redirectUrlResult = redirectUrlTransformer.transform(destination: value.redirectUrl)

        var errors: [(String, TransformerError)] = []
        esiaUrlResult.error.map { errors.append((esiaUrlName, $0)) }
        redirectUrlResult.error.map { errors.append((redirectUrlName, $0)) }

        guard
            let esiaUrl = esiaUrlResult.value,
            let redirectUrl = redirectUrlResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[esiaUrlName] = esiaUrl
        dictionary[redirectUrlName] = redirectUrl
        return .success(dictionary)
    }
}
