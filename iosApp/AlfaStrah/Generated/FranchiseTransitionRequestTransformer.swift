// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct FranchiseTransitionRequestTransformer: Transformer {
    typealias Source = Any
    typealias Destination = FranchiseTransitionRequest

    let insuranceIdName = "insurance_id"
    let personIdsName = "person_ids"

    let insuranceIdTransformer = IdTransformer<Any>()
    let personIdsTransformer = ArrayTransformer(from: Any.self, transformer: NumberTransformer<Any, Int>(), skipFailures: true)

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let insuranceIdResult = dictionary[insuranceIdName].map(insuranceIdTransformer.transform(source:)) ?? .failure(.requirement)
        let personIdsResult = dictionary[personIdsName].map(personIdsTransformer.transform(source:)) ?? .failure(.requirement)

        var errors: [(String, TransformerError)] = []
        insuranceIdResult.error.map { errors.append((insuranceIdName, $0)) }
        personIdsResult.error.map { errors.append((personIdsName, $0)) }

        guard
            let insuranceId = insuranceIdResult.value,
            let personIds = personIdsResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                insuranceId: insuranceId,
                personIds: personIds
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let insuranceIdResult = insuranceIdTransformer.transform(destination: value.insuranceId)
        let personIdsResult = personIdsTransformer.transform(destination: value.personIds)

        var errors: [(String, TransformerError)] = []
        insuranceIdResult.error.map { errors.append((insuranceIdName, $0)) }
        personIdsResult.error.map { errors.append((personIdsName, $0)) }

        guard
            let insuranceId = insuranceIdResult.value,
            let personIds = personIdsResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[insuranceIdName] = insuranceId
        dictionary[personIdsName] = personIds
        return .success(dictionary)
    }
}
