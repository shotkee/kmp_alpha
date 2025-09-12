// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct ResendPartnerEmailCodeResponseTransformer: Transformer {
    typealias Source = Any
    typealias Destination = ResendPartnerEmailCodeResponse

    let emailName = "email"
    let emailCodePartnerResendTimeIntervalName = "code_time"

    let emailTransformer = CastTransformer<Any, String>()
    let emailCodePartnerResendTimeIntervalTransformer = NumberTransformer<Any, TimeInterval>()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let emailResult = dictionary[emailName].map(emailTransformer.transform(source:)) ?? .failure(.requirement)
        let emailCodePartnerResendTimeIntervalResult = dictionary[emailCodePartnerResendTimeIntervalName].map(emailCodePartnerResendTimeIntervalTransformer.transform(source:)) ?? .failure(.requirement)

        var errors: [(String, TransformerError)] = []
        emailResult.error.map { errors.append((emailName, $0)) }
        emailCodePartnerResendTimeIntervalResult.error.map { errors.append((emailCodePartnerResendTimeIntervalName, $0)) }

        guard
            let email = emailResult.value,
            let emailCodePartnerResendTimeInterval = emailCodePartnerResendTimeIntervalResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                email: email,
                emailCodePartnerResendTimeInterval: emailCodePartnerResendTimeInterval
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let emailResult = emailTransformer.transform(destination: value.email)
        let emailCodePartnerResendTimeIntervalResult = emailCodePartnerResendTimeIntervalTransformer.transform(destination: value.emailCodePartnerResendTimeInterval)

        var errors: [(String, TransformerError)] = []
        emailResult.error.map { errors.append((emailName, $0)) }
        emailCodePartnerResendTimeIntervalResult.error.map { errors.append((emailCodePartnerResendTimeIntervalName, $0)) }

        guard
            let email = emailResult.value,
            let emailCodePartnerResendTimeInterval = emailCodePartnerResendTimeIntervalResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[emailName] = email
        dictionary[emailCodePartnerResendTimeIntervalName] = emailCodePartnerResendTimeInterval
        return .success(dictionary)
    }
}
