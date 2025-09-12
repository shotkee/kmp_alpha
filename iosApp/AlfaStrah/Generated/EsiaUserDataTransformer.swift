// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct EsiaUserDataTransformer: Transformer {
    typealias Source = Any
    typealias Destination = EsiaUserData

    let tokenScsName = "esia_refresh_token"
    let sdkAccessTokenName = "esia_access_token"
    let userName = "person"

    let tokenScsTransformer = CastTransformer<Any, String>()
    let sdkAccessTokenTransformer = CastTransformer<Any, String>()
    let userTransformer = EsiaUserTransformer()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let tokenScsResult = dictionary[tokenScsName].map(tokenScsTransformer.transform(source:)) ?? .failure(.requirement)
        let sdkAccessTokenResult = dictionary[sdkAccessTokenName].map(sdkAccessTokenTransformer.transform(source:)) ?? .failure(.requirement)
        let userResult = dictionary[userName].map(userTransformer.transform(source:)) ?? .failure(.requirement)

        var errors: [(String, TransformerError)] = []
        tokenScsResult.error.map { errors.append((tokenScsName, $0)) }
        sdkAccessTokenResult.error.map { errors.append((sdkAccessTokenName, $0)) }
        userResult.error.map { errors.append((userName, $0)) }

        guard
            let tokenScs = tokenScsResult.value,
            let sdkAccessToken = sdkAccessTokenResult.value,
            let user = userResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                tokenScs: tokenScs,
                sdkAccessToken: sdkAccessToken,
                user: user
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let tokenScsResult = tokenScsTransformer.transform(destination: value.tokenScs)
        let sdkAccessTokenResult = sdkAccessTokenTransformer.transform(destination: value.sdkAccessToken)
        let userResult = userTransformer.transform(destination: value.user)

        var errors: [(String, TransformerError)] = []
        tokenScsResult.error.map { errors.append((tokenScsName, $0)) }
        sdkAccessTokenResult.error.map { errors.append((sdkAccessTokenName, $0)) }
        userResult.error.map { errors.append((userName, $0)) }

        guard
            let tokenScs = tokenScsResult.value,
            let sdkAccessToken = sdkAccessTokenResult.value,
            let user = userResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[tokenScsName] = tokenScs
        dictionary[sdkAccessTokenName] = sdkAccessToken
        dictionary[userName] = user
        return .success(dictionary)
    }
}
