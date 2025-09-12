// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct CheckBirthdayResponseTransformer: Transformer {
    typealias Source = Any
    typealias Destination = CheckBirthdayResponse

    let accountIdName = "account_id"
    let phoneName = "phone"
    let emailName = "email"
    let smsCodeVerificationResendTimeIntervalName = "code_time_phone"
    let emailCodeVerificationResendTimeIntervalName = "code_time_email"

    let accountIdTransformer = IdTransformer<Any>()
    let phoneTransformer = PhoneTransformer()
    let emailTransformer = CastTransformer<Any, String>()
    let smsCodeVerificationResendTimeIntervalTransformer = NumberTransformer<Any, TimeInterval>()
    let emailCodeVerificationResendTimeIntervalTransformer = NumberTransformer<Any, TimeInterval>()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let accountIdResult = dictionary[accountIdName].map(accountIdTransformer.transform(source:)) ?? .failure(.requirement)
        let phoneResult = dictionary[phoneName].map(phoneTransformer.transform(source:)) ?? .failure(.requirement)
        let emailResult = dictionary[emailName].map(emailTransformer.transform(source:)) ?? .failure(.requirement)
        let smsCodeVerificationResendTimeIntervalResult = dictionary[smsCodeVerificationResendTimeIntervalName].map(smsCodeVerificationResendTimeIntervalTransformer.transform(source:)) ?? .failure(.requirement)
        let emailCodeVerificationResendTimeIntervalResult = dictionary[emailCodeVerificationResendTimeIntervalName].map(emailCodeVerificationResendTimeIntervalTransformer.transform(source:)) ?? .failure(.requirement)

        var errors: [(String, TransformerError)] = []
        accountIdResult.error.map { errors.append((accountIdName, $0)) }
        phoneResult.error.map { errors.append((phoneName, $0)) }
        emailResult.error.map { errors.append((emailName, $0)) }
        smsCodeVerificationResendTimeIntervalResult.error.map { errors.append((smsCodeVerificationResendTimeIntervalName, $0)) }
        emailCodeVerificationResendTimeIntervalResult.error.map { errors.append((emailCodeVerificationResendTimeIntervalName, $0)) }

        guard
            let accountId = accountIdResult.value,
            let phone = phoneResult.value,
            let email = emailResult.value,
            let smsCodeVerificationResendTimeInterval = smsCodeVerificationResendTimeIntervalResult.value,
            let emailCodeVerificationResendTimeInterval = emailCodeVerificationResendTimeIntervalResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                accountId: accountId,
                phone: phone,
                email: email,
                smsCodeVerificationResendTimeInterval: smsCodeVerificationResendTimeInterval,
                emailCodeVerificationResendTimeInterval: emailCodeVerificationResendTimeInterval
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let accountIdResult = accountIdTransformer.transform(destination: value.accountId)
        let phoneResult = phoneTransformer.transform(destination: value.phone)
        let emailResult = emailTransformer.transform(destination: value.email)
        let smsCodeVerificationResendTimeIntervalResult = smsCodeVerificationResendTimeIntervalTransformer.transform(destination: value.smsCodeVerificationResendTimeInterval)
        let emailCodeVerificationResendTimeIntervalResult = emailCodeVerificationResendTimeIntervalTransformer.transform(destination: value.emailCodeVerificationResendTimeInterval)

        var errors: [(String, TransformerError)] = []
        accountIdResult.error.map { errors.append((accountIdName, $0)) }
        phoneResult.error.map { errors.append((phoneName, $0)) }
        emailResult.error.map { errors.append((emailName, $0)) }
        smsCodeVerificationResendTimeIntervalResult.error.map { errors.append((smsCodeVerificationResendTimeIntervalName, $0)) }
        emailCodeVerificationResendTimeIntervalResult.error.map { errors.append((emailCodeVerificationResendTimeIntervalName, $0)) }

        guard
            let accountId = accountIdResult.value,
            let phone = phoneResult.value,
            let email = emailResult.value,
            let smsCodeVerificationResendTimeInterval = smsCodeVerificationResendTimeIntervalResult.value,
            let emailCodeVerificationResendTimeInterval = emailCodeVerificationResendTimeIntervalResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[accountIdName] = accountId
        dictionary[phoneName] = phone
        dictionary[emailName] = email
        dictionary[smsCodeVerificationResendTimeIntervalName] = smsCodeVerificationResendTimeInterval
        dictionary[emailCodeVerificationResendTimeIntervalName] = emailCodeVerificationResendTimeInterval
        return .success(dictionary)
    }
}
