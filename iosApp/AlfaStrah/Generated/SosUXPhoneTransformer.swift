// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct SosUXPhoneTransformer: Transformer {
    typealias Source = Any
    typealias Destination = SosUXPhone

    let phoneNumberName = "call_phone"

    let phoneNumberTransformer = CastTransformer<Any, String>()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let phoneNumberResult = dictionary[phoneNumberName].map(phoneNumberTransformer.transform(source:)) ?? .failure(.requirement)

        var errors: [(String, TransformerError)] = []
        phoneNumberResult.error.map { errors.append((phoneNumberName, $0)) }

        guard
            let phoneNumber = phoneNumberResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                phoneNumber: phoneNumber
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let phoneNumberResult = phoneNumberTransformer.transform(destination: value.phoneNumber)

        var errors: [(String, TransformerError)] = []
        phoneNumberResult.error.map { errors.append((phoneNumberName, $0)) }

        guard
            let phoneNumber = phoneNumberResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[phoneNumberName] = phoneNumber
        return .success(dictionary)
    }
}
