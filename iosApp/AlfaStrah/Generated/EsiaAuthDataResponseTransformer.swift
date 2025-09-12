// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct EsiaAuthDataResponseTransformer: Transformer {
    typealias Source = Any
    typealias Destination = EsiaAuthDataResponse

    let redirectUrlName = "redirect_url"
    let regexpName = "regexp"
    let esiaTokenCookieFieldNameName = "token_cookie_name"

    let redirectUrlTransformer = UrlTransformer<Any>()
    let regexpTransformer = CastTransformer<Any, String>()
    let esiaTokenCookieFieldNameTransformer = CastTransformer<Any, String>()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let redirectUrlResult = dictionary[redirectUrlName].map(redirectUrlTransformer.transform(source:)) ?? .failure(.requirement)
        let regexpResult = dictionary[regexpName].map(regexpTransformer.transform(source:)) ?? .failure(.requirement)
        let esiaTokenCookieFieldNameResult = dictionary[esiaTokenCookieFieldNameName].map(esiaTokenCookieFieldNameTransformer.transform(source:)) ?? .failure(.requirement)

        var errors: [(String, TransformerError)] = []
        redirectUrlResult.error.map { errors.append((redirectUrlName, $0)) }
        regexpResult.error.map { errors.append((regexpName, $0)) }
        esiaTokenCookieFieldNameResult.error.map { errors.append((esiaTokenCookieFieldNameName, $0)) }

        guard
            let redirectUrl = redirectUrlResult.value,
            let regexp = regexpResult.value,
            let esiaTokenCookieFieldName = esiaTokenCookieFieldNameResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                redirectUrl: redirectUrl,
                regexp: regexp,
                esiaTokenCookieFieldName: esiaTokenCookieFieldName
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let redirectUrlResult = redirectUrlTransformer.transform(destination: value.redirectUrl)
        let regexpResult = regexpTransformer.transform(destination: value.regexp)
        let esiaTokenCookieFieldNameResult = esiaTokenCookieFieldNameTransformer.transform(destination: value.esiaTokenCookieFieldName)

        var errors: [(String, TransformerError)] = []
        redirectUrlResult.error.map { errors.append((redirectUrlName, $0)) }
        regexpResult.error.map { errors.append((regexpName, $0)) }
        esiaTokenCookieFieldNameResult.error.map { errors.append((esiaTokenCookieFieldNameName, $0)) }

        guard
            let redirectUrl = redirectUrlResult.value,
            let regexp = regexpResult.value,
            let esiaTokenCookieFieldName = esiaTokenCookieFieldNameResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[redirectUrlName] = redirectUrl
        dictionary[regexpName] = regexp
        dictionary[esiaTokenCookieFieldNameName] = esiaTokenCookieFieldName
        return .success(dictionary)
    }
}
