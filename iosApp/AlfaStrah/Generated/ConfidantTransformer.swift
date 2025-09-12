// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct ConfidantTransformer: Transformer {
    typealias Source = Any
    typealias Destination = Confidant

    let nameName = "name"
    let phoneName = "phone"

    let nameTransformer = CastTransformer<Any, String>()
    let phoneTransformer = PhoneTransformer()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let nameResult = dictionary[nameName].map(nameTransformer.transform(source:)) ?? .failure(.requirement)
        let phoneResult = dictionary[phoneName].map(phoneTransformer.transform(source:)) ?? .failure(.requirement)

        var errors: [(String, TransformerError)] = []
        nameResult.error.map { errors.append((nameName, $0)) }
        phoneResult.error.map { errors.append((phoneName, $0)) }

        guard
            let name = nameResult.value,
            let phone = phoneResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                name: name,
                phone: phone
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let nameResult = nameTransformer.transform(destination: value.name)
        let phoneResult = phoneTransformer.transform(destination: value.phone)

        var errors: [(String, TransformerError)] = []
        nameResult.error.map { errors.append((nameName, $0)) }
        phoneResult.error.map { errors.append((phoneName, $0)) }

        guard
            let name = nameResult.value,
            let phone = phoneResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[nameName] = name
        dictionary[phoneName] = phone
        return .success(dictionary)
    }
}
