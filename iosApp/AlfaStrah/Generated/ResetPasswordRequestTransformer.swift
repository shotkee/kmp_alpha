// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct ResetPasswordRequestTransformer: Transformer {
    typealias Source = Any
    typealias Destination = ResetPasswordRequest

    let emailName = "email"
    let phoneNumberName = "phone_number"

    let emailTransformer = CastTransformer<Any, String>()
    let phoneNumberTransformer = CastTransformer<Any, String>()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let emailResult = dictionary[emailName].map(emailTransformer.transform(source:)) ?? .failure(.requirement)
        let phoneNumberResult = dictionary[phoneNumberName].map(phoneNumberTransformer.transform(source:)) ?? .failure(.requirement)

        var errors: [(String, TransformerError)] = []
        emailResult.error.map { errors.append((emailName, $0)) }
        phoneNumberResult.error.map { errors.append((phoneNumberName, $0)) }

        guard
            let email = emailResult.value,
            let phoneNumber = phoneNumberResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                email: email,
                phoneNumber: phoneNumber
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let emailResult = emailTransformer.transform(destination: value.email)
        let phoneNumberResult = phoneNumberTransformer.transform(destination: value.phoneNumber)

        var errors: [(String, TransformerError)] = []
        emailResult.error.map { errors.append((emailName, $0)) }
        phoneNumberResult.error.map { errors.append((phoneNumberName, $0)) }

        guard
            let email = emailResult.value,
            let phoneNumber = phoneNumberResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[emailName] = email
        dictionary[phoneNumberName] = phoneNumber
        return .success(dictionary)
    }
}
