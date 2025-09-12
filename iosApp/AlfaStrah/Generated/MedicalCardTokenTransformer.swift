// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct MedicalCardTokenTransformer: Transformer {
    typealias Source = Any
    typealias Destination = MedicalCardToken

    let tokenName = "token"
    let expirationDateName = "datetime_expire"

    let tokenTransformer = CastTransformer<Any, String>()
    let expirationDateTransformer = DateTransformer<Any>()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let tokenResult = dictionary[tokenName].map(tokenTransformer.transform(source:)) ?? .failure(.requirement)
        let expirationDateResult = dictionary[expirationDateName].map(expirationDateTransformer.transform(source:)) ?? .failure(.requirement)

        var errors: [(String, TransformerError)] = []
        tokenResult.error.map { errors.append((tokenName, $0)) }
        expirationDateResult.error.map { errors.append((expirationDateName, $0)) }

        guard
            let token = tokenResult.value,
            let expirationDate = expirationDateResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                token: token,
                expirationDate: expirationDate
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let tokenResult = tokenTransformer.transform(destination: value.token)
        let expirationDateResult = expirationDateTransformer.transform(destination: value.expirationDate)

        var errors: [(String, TransformerError)] = []
        tokenResult.error.map { errors.append((tokenName, $0)) }
        expirationDateResult.error.map { errors.append((expirationDateName, $0)) }

        guard
            let token = tokenResult.value,
            let expirationDate = expirationDateResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[tokenName] = token
        dictionary[expirationDateName] = expirationDate
        return .success(dictionary)
    }
}
