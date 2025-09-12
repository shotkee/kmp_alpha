// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct ResendPartnerSmsCodeResponseTransformer: Transformer {
    typealias Source = Any
    typealias Destination = ResendPartnerSmsCodeResponse

    let phoneName = "phone"
    let smsCodePartnerResendTimeIntervalName = "code_time"

    let phoneTransformer = PhoneTransformer()
    let smsCodePartnerResendTimeIntervalTransformer = NumberTransformer<Any, TimeInterval>()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let phoneResult = dictionary[phoneName].map(phoneTransformer.transform(source:)) ?? .failure(.requirement)
        let smsCodePartnerResendTimeIntervalResult = dictionary[smsCodePartnerResendTimeIntervalName].map(smsCodePartnerResendTimeIntervalTransformer.transform(source:)) ?? .failure(.requirement)

        var errors: [(String, TransformerError)] = []
        phoneResult.error.map { errors.append((phoneName, $0)) }
        smsCodePartnerResendTimeIntervalResult.error.map { errors.append((smsCodePartnerResendTimeIntervalName, $0)) }

        guard
            let phone = phoneResult.value,
            let smsCodePartnerResendTimeInterval = smsCodePartnerResendTimeIntervalResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                phone: phone,
                smsCodePartnerResendTimeInterval: smsCodePartnerResendTimeInterval
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let phoneResult = phoneTransformer.transform(destination: value.phone)
        let smsCodePartnerResendTimeIntervalResult = smsCodePartnerResendTimeIntervalTransformer.transform(destination: value.smsCodePartnerResendTimeInterval)

        var errors: [(String, TransformerError)] = []
        phoneResult.error.map { errors.append((phoneName, $0)) }
        smsCodePartnerResendTimeIntervalResult.error.map { errors.append((smsCodePartnerResendTimeIntervalName, $0)) }

        guard
            let phone = phoneResult.value,
            let smsCodePartnerResendTimeInterval = smsCodePartnerResendTimeIntervalResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[phoneName] = phone
        dictionary[smsCodePartnerResendTimeIntervalName] = smsCodePartnerResendTimeInterval
        return .success(dictionary)
    }
}
