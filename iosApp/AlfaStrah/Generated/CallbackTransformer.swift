// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct CallbackTransformer: Transformer {
    typealias Source = Any
    typealias Destination = Callback

    let coordinateName = "coordinate"
    let phoneName = "phone"
    let messageName = "message"
    let addressName = "address"
    let insuranceIdName = "insurance_id"

    let coordinateTransformer = OptionalTransformer(transformer: CoordinateTransformer())
    let phoneTransformer = CastTransformer<Any, String>()
    let messageTransformer = OptionalTransformer(transformer: CastTransformer<Any, String>())
    let addressTransformer = OptionalTransformer(transformer: CastTransformer<Any, String>())
    let insuranceIdTransformer = IdTransformer<Any>()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let coordinateResult = coordinateTransformer.transform(source: dictionary[coordinateName])
        let phoneResult = dictionary[phoneName].map(phoneTransformer.transform(source:)) ?? .failure(.requirement)
        let messageResult = messageTransformer.transform(source: dictionary[messageName])
        let addressResult = addressTransformer.transform(source: dictionary[addressName])
        let insuranceIdResult = dictionary[insuranceIdName].map(insuranceIdTransformer.transform(source:)) ?? .failure(.requirement)

        var errors: [(String, TransformerError)] = []
        coordinateResult.error.map { errors.append((coordinateName, $0)) }
        phoneResult.error.map { errors.append((phoneName, $0)) }
        messageResult.error.map { errors.append((messageName, $0)) }
        addressResult.error.map { errors.append((addressName, $0)) }
        insuranceIdResult.error.map { errors.append((insuranceIdName, $0)) }

        guard
            let coordinate = coordinateResult.value,
            let phone = phoneResult.value,
            let message = messageResult.value,
            let address = addressResult.value,
            let insuranceId = insuranceIdResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                coordinate: coordinate,
                phone: phone,
                message: message,
                address: address,
                insuranceId: insuranceId
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let coordinateResult = coordinateTransformer.transform(destination: value.coordinate)
        let phoneResult = phoneTransformer.transform(destination: value.phone)
        let messageResult = messageTransformer.transform(destination: value.message)
        let addressResult = addressTransformer.transform(destination: value.address)
        let insuranceIdResult = insuranceIdTransformer.transform(destination: value.insuranceId)

        var errors: [(String, TransformerError)] = []
        coordinateResult.error.map { errors.append((coordinateName, $0)) }
        phoneResult.error.map { errors.append((phoneName, $0)) }
        messageResult.error.map { errors.append((messageName, $0)) }
        addressResult.error.map { errors.append((addressName, $0)) }
        insuranceIdResult.error.map { errors.append((insuranceIdName, $0)) }

        guard
            let coordinate = coordinateResult.value,
            let phone = phoneResult.value,
            let message = messageResult.value,
            let address = addressResult.value,
            let insuranceId = insuranceIdResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[coordinateName] = coordinate
        dictionary[phoneName] = phone
        dictionary[messageName] = message
        dictionary[addressName] = address
        dictionary[insuranceIdName] = insuranceId
        return .success(dictionary)
    }
}
