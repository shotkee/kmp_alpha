// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct CheckPatnerCodesRequestTransformer: Transformer {
    typealias Source = Any
    typealias Destination = CheckPatnerCodesRequest

    let accountIdName = "account_id"
    let phoneCodeName = "phone_code"
    let emailCodeName = "email_code"

    let accountIdTransformer = IdTransformer<Any>()
    let phoneCodeTransformer = CastTransformer<Any, String>()
    let emailCodeTransformer = CastTransformer<Any, String>()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let accountIdResult = dictionary[accountIdName].map(accountIdTransformer.transform(source:)) ?? .failure(.requirement)
        let phoneCodeResult = dictionary[phoneCodeName].map(phoneCodeTransformer.transform(source:)) ?? .failure(.requirement)
        let emailCodeResult = dictionary[emailCodeName].map(emailCodeTransformer.transform(source:)) ?? .failure(.requirement)

        var errors: [(String, TransformerError)] = []
        accountIdResult.error.map { errors.append((accountIdName, $0)) }
        phoneCodeResult.error.map { errors.append((phoneCodeName, $0)) }
        emailCodeResult.error.map { errors.append((emailCodeName, $0)) }

        guard
            let accountId = accountIdResult.value,
            let phoneCode = phoneCodeResult.value,
            let emailCode = emailCodeResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                accountId: accountId,
                phoneCode: phoneCode,
                emailCode: emailCode
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let accountIdResult = accountIdTransformer.transform(destination: value.accountId)
        let phoneCodeResult = phoneCodeTransformer.transform(destination: value.phoneCode)
        let emailCodeResult = emailCodeTransformer.transform(destination: value.emailCode)

        var errors: [(String, TransformerError)] = []
        accountIdResult.error.map { errors.append((accountIdName, $0)) }
        phoneCodeResult.error.map { errors.append((phoneCodeName, $0)) }
        emailCodeResult.error.map { errors.append((emailCodeName, $0)) }

        guard
            let accountId = accountIdResult.value,
            let phoneCode = phoneCodeResult.value,
            let emailCode = emailCodeResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[accountIdName] = accountId
        dictionary[phoneCodeName] = phoneCode
        dictionary[emailCodeName] = emailCode
        return .success(dictionary)
    }
}
