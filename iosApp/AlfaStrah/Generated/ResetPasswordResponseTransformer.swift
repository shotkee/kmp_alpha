// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct ResetPasswordResponseTransformer: Transformer {
    typealias Source = Any
    typealias Destination = ResetPasswordResponse

    let accountIdName = "account_id"
    let phoneName = "phone"
    let otpVerificationResendTimeIntervalName = "code_time"
    let passRecoveryFlowName = "flow"

    let accountIdTransformer = IdTransformer<Any>()
    let phoneTransformer = PhoneTransformer()
    let otpVerificationResendTimeIntervalTransformer = NumberTransformer<Any, TimeInterval>()
    let passRecoveryFlowTransformer = ResetPasswordResponsePassRecoveryFlowTransformer()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let accountIdResult = dictionary[accountIdName].map(accountIdTransformer.transform(source:)) ?? .failure(.requirement)
        let phoneResult = dictionary[phoneName].map(phoneTransformer.transform(source:)) ?? .failure(.requirement)
        let otpVerificationResendTimeIntervalResult = dictionary[otpVerificationResendTimeIntervalName].map(otpVerificationResendTimeIntervalTransformer.transform(source:)) ?? .failure(.requirement)
        let passRecoveryFlowResult = dictionary[passRecoveryFlowName].map(passRecoveryFlowTransformer.transform(source:)) ?? .failure(.requirement)

        var errors: [(String, TransformerError)] = []
        accountIdResult.error.map { errors.append((accountIdName, $0)) }
        phoneResult.error.map { errors.append((phoneName, $0)) }
        otpVerificationResendTimeIntervalResult.error.map { errors.append((otpVerificationResendTimeIntervalName, $0)) }
        passRecoveryFlowResult.error.map { errors.append((passRecoveryFlowName, $0)) }

        guard
            let accountId = accountIdResult.value,
            let phone = phoneResult.value,
            let otpVerificationResendTimeInterval = otpVerificationResendTimeIntervalResult.value,
            let passRecoveryFlow = passRecoveryFlowResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                accountId: accountId,
                phone: phone,
                otpVerificationResendTimeInterval: otpVerificationResendTimeInterval,
                passRecoveryFlow: passRecoveryFlow
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let accountIdResult = accountIdTransformer.transform(destination: value.accountId)
        let phoneResult = phoneTransformer.transform(destination: value.phone)
        let otpVerificationResendTimeIntervalResult = otpVerificationResendTimeIntervalTransformer.transform(destination: value.otpVerificationResendTimeInterval)
        let passRecoveryFlowResult = passRecoveryFlowTransformer.transform(destination: value.passRecoveryFlow)

        var errors: [(String, TransformerError)] = []
        accountIdResult.error.map { errors.append((accountIdName, $0)) }
        phoneResult.error.map { errors.append((phoneName, $0)) }
        otpVerificationResendTimeIntervalResult.error.map { errors.append((otpVerificationResendTimeIntervalName, $0)) }
        passRecoveryFlowResult.error.map { errors.append((passRecoveryFlowName, $0)) }

        guard
            let accountId = accountIdResult.value,
            let phone = phoneResult.value,
            let otpVerificationResendTimeInterval = otpVerificationResendTimeIntervalResult.value,
            let passRecoveryFlow = passRecoveryFlowResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[accountIdName] = accountId
        dictionary[phoneName] = phone
        dictionary[otpVerificationResendTimeIntervalName] = otpVerificationResendTimeInterval
        dictionary[passRecoveryFlowName] = passRecoveryFlow
        return .success(dictionary)
    }
}
