// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct UpdateAccountResponseTransformer: Transformer {
    typealias Source = Any
    typealias Destination = UpdateAccountResponse

    let accountName = "account"
    let otpVerificationResendTimeIntervalName = "code_time"

    let accountTransformer = AccountTransformer()
    let otpVerificationResendTimeIntervalTransformer = NumberTransformer<Any, TimeInterval>()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let accountResult = dictionary[accountName].map(accountTransformer.transform(source:)) ?? .failure(.requirement)
        let otpVerificationResendTimeIntervalResult = dictionary[otpVerificationResendTimeIntervalName].map(otpVerificationResendTimeIntervalTransformer.transform(source:)) ?? .failure(.requirement)

        var errors: [(String, TransformerError)] = []
        accountResult.error.map { errors.append((accountName, $0)) }
        otpVerificationResendTimeIntervalResult.error.map { errors.append((otpVerificationResendTimeIntervalName, $0)) }

        guard
            let account = accountResult.value,
            let otpVerificationResendTimeInterval = otpVerificationResendTimeIntervalResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                account: account,
                otpVerificationResendTimeInterval: otpVerificationResendTimeInterval
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let accountResult = accountTransformer.transform(destination: value.account)
        let otpVerificationResendTimeIntervalResult = otpVerificationResendTimeIntervalTransformer.transform(destination: value.otpVerificationResendTimeInterval)

        var errors: [(String, TransformerError)] = []
        accountResult.error.map { errors.append((accountName, $0)) }
        otpVerificationResendTimeIntervalResult.error.map { errors.append((otpVerificationResendTimeIntervalName, $0)) }

        guard
            let account = accountResult.value,
            let otpVerificationResendTimeInterval = otpVerificationResendTimeIntervalResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[accountName] = account
        dictionary[otpVerificationResendTimeIntervalName] = otpVerificationResendTimeInterval
        return .success(dictionary)
    }
}
