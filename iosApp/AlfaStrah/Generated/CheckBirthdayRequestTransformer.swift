// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct CheckBirthdayRequestTransformer: Transformer {
    typealias Source = Any
    typealias Destination = CheckBirthdayRequest

    let accountIdName = "account_id"
    let birthDateName = "birthday"
    let emailName = "email"

    let accountIdTransformer = IdTransformer<Any>()
    let birthDateTransformer = DateTransformer<Any>(format: "yyyy-MM-dd", locale: AppLocale.currentLocale)
    let emailTransformer = CastTransformer<Any, String>()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let accountIdResult = dictionary[accountIdName].map(accountIdTransformer.transform(source:)) ?? .failure(.requirement)
        let birthDateResult = dictionary[birthDateName].map(birthDateTransformer.transform(source:)) ?? .failure(.requirement)
        let emailResult = dictionary[emailName].map(emailTransformer.transform(source:)) ?? .failure(.requirement)

        var errors: [(String, TransformerError)] = []
        accountIdResult.error.map { errors.append((accountIdName, $0)) }
        birthDateResult.error.map { errors.append((birthDateName, $0)) }
        emailResult.error.map { errors.append((emailName, $0)) }

        guard
            let accountId = accountIdResult.value,
            let birthDate = birthDateResult.value,
            let email = emailResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                accountId: accountId,
                birthDate: birthDate,
                email: email
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let accountIdResult = accountIdTransformer.transform(destination: value.accountId)
        let birthDateResult = birthDateTransformer.transform(destination: value.birthDate)
        let emailResult = emailTransformer.transform(destination: value.email)

        var errors: [(String, TransformerError)] = []
        accountIdResult.error.map { errors.append((accountIdName, $0)) }
        birthDateResult.error.map { errors.append((birthDateName, $0)) }
        emailResult.error.map { errors.append((emailName, $0)) }

        guard
            let accountId = accountIdResult.value,
            let birthDate = birthDateResult.value,
            let email = emailResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[accountIdName] = accountId
        dictionary[birthDateName] = birthDate
        dictionary[emailName] = email
        return .success(dictionary)
    }
}
