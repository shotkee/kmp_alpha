// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct DmsCostRecoveryRequisitesTransformer: Transformer {
    typealias Source = Any
    typealias Destination = DmsCostRecoveryRequisites

    let bankName = "bank"
    let accountNumberName = "account_number"

    let bankTransformer = DmsCostRecoveryBankTransformer()
    let accountNumberTransformer = CastTransformer<Any, String>()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let bankResult = dictionary[bankName].map(bankTransformer.transform(source:)) ?? .failure(.requirement)
        let accountNumberResult = dictionary[accountNumberName].map(accountNumberTransformer.transform(source:)) ?? .failure(.requirement)

        var errors: [(String, TransformerError)] = []
        bankResult.error.map { errors.append((bankName, $0)) }
        accountNumberResult.error.map { errors.append((accountNumberName, $0)) }

        guard
            let bank = bankResult.value,
            let accountNumber = accountNumberResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                bank: bank,
                accountNumber: accountNumber
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let bankResult = bankTransformer.transform(destination: value.bank)
        let accountNumberResult = accountNumberTransformer.transform(destination: value.accountNumber)

        var errors: [(String, TransformerError)] = []
        bankResult.error.map { errors.append((bankName, $0)) }
        accountNumberResult.error.map { errors.append((accountNumberName, $0)) }

        guard
            let bank = bankResult.value,
            let accountNumber = accountNumberResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[bankName] = bank
        dictionary[accountNumberName] = accountNumber
        return .success(dictionary)
    }
}
