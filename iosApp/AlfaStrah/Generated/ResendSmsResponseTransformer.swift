// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct ResendSmsResponseTransformer: Transformer {
    typealias Source = Any
    typealias Destination = ResendSmsResponse

    let phoneName = "phone"
    let otpVerificationResendTimeIntervalName = "code_time"

    let phoneTransformer = PhoneTransformer()
    let otpVerificationResendTimeIntervalTransformer = NumberTransformer<Any, TimeInterval>()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let phoneResult = dictionary[phoneName].map(phoneTransformer.transform(source:)) ?? .failure(.requirement)
        let otpVerificationResendTimeIntervalResult = dictionary[otpVerificationResendTimeIntervalName].map(otpVerificationResendTimeIntervalTransformer.transform(source:)) ?? .failure(.requirement)

        var errors: [(String, TransformerError)] = []
        phoneResult.error.map { errors.append((phoneName, $0)) }
        otpVerificationResendTimeIntervalResult.error.map { errors.append((otpVerificationResendTimeIntervalName, $0)) }

        guard
            let phone = phoneResult.value,
            let otpVerificationResendTimeInterval = otpVerificationResendTimeIntervalResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                phone: phone,
                otpVerificationResendTimeInterval: otpVerificationResendTimeInterval
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let phoneResult = phoneTransformer.transform(destination: value.phone)
        let otpVerificationResendTimeIntervalResult = otpVerificationResendTimeIntervalTransformer.transform(destination: value.otpVerificationResendTimeInterval)

        var errors: [(String, TransformerError)] = []
        phoneResult.error.map { errors.append((phoneName, $0)) }
        otpVerificationResendTimeIntervalResult.error.map { errors.append((otpVerificationResendTimeIntervalName, $0)) }

        guard
            let phone = phoneResult.value,
            let otpVerificationResendTimeInterval = otpVerificationResendTimeIntervalResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[phoneName] = phone
        dictionary[otpVerificationResendTimeIntervalName] = otpVerificationResendTimeInterval
        return .success(dictionary)
    }
}
