// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct CascanaChatSessionTransformer: Transformer {
    typealias Source = Any
    typealias Destination = CascanaChatSession

    let accessTokenName = "cascana_token"
    let refreshTokenName = "refresh_token"

    let accessTokenTransformer = CastTransformer<Any, String>()
    let refreshTokenTransformer = OptionalTransformer(transformer: CastTransformer<Any, String>())

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let accessTokenResult = dictionary[accessTokenName].map(accessTokenTransformer.transform(source:)) ?? .failure(.requirement)
        let refreshTokenResult = refreshTokenTransformer.transform(source: dictionary[refreshTokenName])

        var errors: [(String, TransformerError)] = []
        accessTokenResult.error.map { errors.append((accessTokenName, $0)) }
        refreshTokenResult.error.map { errors.append((refreshTokenName, $0)) }

        guard
            let accessToken = accessTokenResult.value,
            let refreshToken = refreshTokenResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                accessToken: accessToken,
                refreshToken: refreshToken
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let accessTokenResult = accessTokenTransformer.transform(destination: value.accessToken)
        let refreshTokenResult = refreshTokenTransformer.transform(destination: value.refreshToken)

        var errors: [(String, TransformerError)] = []
        accessTokenResult.error.map { errors.append((accessTokenName, $0)) }
        refreshTokenResult.error.map { errors.append((refreshTokenName, $0)) }

        guard
            let accessToken = accessTokenResult.value,
            let refreshToken = refreshTokenResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[accessTokenName] = accessToken
        dictionary[refreshTokenName] = refreshToken
        return .success(dictionary)
    }
}
