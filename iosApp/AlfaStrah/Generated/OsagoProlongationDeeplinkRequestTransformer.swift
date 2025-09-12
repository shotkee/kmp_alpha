// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct OsagoProlongationDeeplinkRequestTransformer: Transformer {
    typealias Source = Any
    typealias Destination = OsagoProlongationDeeplinkRequest

    let insuranceIdName = "insurance_id"
    let agreedToPersonalDataPolicyName = "agreed"

    let insuranceIdTransformer = CastTransformer<Any, String>()
    let agreedToPersonalDataPolicyTransformer = NumberTransformer<Any, Bool>()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let insuranceIdResult = dictionary[insuranceIdName].map(insuranceIdTransformer.transform(source:)) ?? .failure(.requirement)
        let agreedToPersonalDataPolicyResult = dictionary[agreedToPersonalDataPolicyName].map(agreedToPersonalDataPolicyTransformer.transform(source:)) ?? .failure(.requirement)

        var errors: [(String, TransformerError)] = []
        insuranceIdResult.error.map { errors.append((insuranceIdName, $0)) }
        agreedToPersonalDataPolicyResult.error.map { errors.append((agreedToPersonalDataPolicyName, $0)) }

        guard
            let insuranceId = insuranceIdResult.value,
            let agreedToPersonalDataPolicy = agreedToPersonalDataPolicyResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                insuranceId: insuranceId,
                agreedToPersonalDataPolicy: agreedToPersonalDataPolicy
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let insuranceIdResult = insuranceIdTransformer.transform(destination: value.insuranceId)
        let agreedToPersonalDataPolicyResult = agreedToPersonalDataPolicyTransformer.transform(destination: value.agreedToPersonalDataPolicy)

        var errors: [(String, TransformerError)] = []
        insuranceIdResult.error.map { errors.append((insuranceIdName, $0)) }
        agreedToPersonalDataPolicyResult.error.map { errors.append((agreedToPersonalDataPolicyName, $0)) }

        guard
            let insuranceId = insuranceIdResult.value,
            let agreedToPersonalDataPolicy = agreedToPersonalDataPolicyResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[insuranceIdName] = insuranceId
        dictionary[agreedToPersonalDataPolicyName] = agreedToPersonalDataPolicy
        return .success(dictionary)
    }
}
