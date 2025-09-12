// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct UserSessionTransformer: Transformer {
    typealias Source = Any
    typealias Destination = UserSession

    let idName = "id"
    let accessTokenName = "access_token"

    let idTransformer = IdTransformer<Any>()
    let accessTokenTransformer = CastTransformer<Any, String>()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let idResult = dictionary[idName].map(idTransformer.transform(source:)) ?? .failure(.requirement)
        let accessTokenResult = dictionary[accessTokenName].map(accessTokenTransformer.transform(source:)) ?? .failure(.requirement)

        var errors: [(String, TransformerError)] = []
        idResult.error.map { errors.append((idName, $0)) }
        accessTokenResult.error.map { errors.append((accessTokenName, $0)) }

        guard
            let id = idResult.value,
            let accessToken = accessTokenResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                id: id,
                accessToken: accessToken
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let idResult = idTransformer.transform(destination: value.id)
        let accessTokenResult = accessTokenTransformer.transform(destination: value.accessToken)

        var errors: [(String, TransformerError)] = []
        idResult.error.map { errors.append((idName, $0)) }
        accessTokenResult.error.map { errors.append((accessTokenName, $0)) }

        guard
            let id = idResult.value,
            let accessToken = accessTokenResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[idName] = id
        dictionary[accessTokenName] = accessToken
        return .success(dictionary)
    }
}
