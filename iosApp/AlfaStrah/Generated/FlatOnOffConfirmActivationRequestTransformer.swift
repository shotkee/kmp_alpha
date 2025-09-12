// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct FlatOnOffConfirmActivationRequestTransformer: Transformer {
    typealias Source = Any
    typealias Destination = FlatOnOffConfirmActivationRequest

    let insuranceIdName = "insurance_id"
    let protectionIdName = "protection_id"

    let insuranceIdTransformer = IdTransformer<Any>()
    let protectionIdTransformer = IdTransformer<Any>()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let insuranceIdResult = dictionary[insuranceIdName].map(insuranceIdTransformer.transform(source:)) ?? .failure(.requirement)
        let protectionIdResult = dictionary[protectionIdName].map(protectionIdTransformer.transform(source:)) ?? .failure(.requirement)

        var errors: [(String, TransformerError)] = []
        insuranceIdResult.error.map { errors.append((insuranceIdName, $0)) }
        protectionIdResult.error.map { errors.append((protectionIdName, $0)) }

        guard
            let insuranceId = insuranceIdResult.value,
            let protectionId = protectionIdResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                insuranceId: insuranceId,
                protectionId: protectionId
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let insuranceIdResult = insuranceIdTransformer.transform(destination: value.insuranceId)
        let protectionIdResult = protectionIdTransformer.transform(destination: value.protectionId)

        var errors: [(String, TransformerError)] = []
        insuranceIdResult.error.map { errors.append((insuranceIdName, $0)) }
        protectionIdResult.error.map { errors.append((protectionIdName, $0)) }

        guard
            let insuranceId = insuranceIdResult.value,
            let protectionId = protectionIdResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[insuranceIdName] = insuranceId
        dictionary[protectionIdName] = protectionId
        return .success(dictionary)
    }
}
