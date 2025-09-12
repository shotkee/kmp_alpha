// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct BankInfoPayloadTransformer: Transformer {
    typealias Source = Any
    typealias Destination = BankInfoPayload

    let bikName = "bik"
    let accountNumberName = "account_number"

    let bikTransformer = CastTransformer<Any, String>()
    let accountNumberTransformer = CastTransformer<Any, String>()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let bikResult = dictionary[bikName].map(bikTransformer.transform(source:)) ?? .failure(.requirement)
        let accountNumberResult = dictionary[accountNumberName].map(accountNumberTransformer.transform(source:)) ?? .failure(.requirement)

        var errors: [(String, TransformerError)] = []
        bikResult.error.map { errors.append((bikName, $0)) }
        accountNumberResult.error.map { errors.append((accountNumberName, $0)) }

        guard
            let bik = bikResult.value,
            let accountNumber = accountNumberResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                bik: bik,
                accountNumber: accountNumber
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let bikResult = bikTransformer.transform(destination: value.bik)
        let accountNumberResult = accountNumberTransformer.transform(destination: value.accountNumber)

        var errors: [(String, TransformerError)] = []
        bikResult.error.map { errors.append((bikName, $0)) }
        accountNumberResult.error.map { errors.append((accountNumberName, $0)) }

        guard
            let bik = bikResult.value,
            let accountNumber = accountNumberResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[bikName] = bik
        dictionary[accountNumberName] = accountNumber
        return .success(dictionary)
    }
}
