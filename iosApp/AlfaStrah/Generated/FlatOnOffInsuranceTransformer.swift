// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct FlatOnOffInsuranceTransformer: Transformer {
    typealias Source = Any
    typealias Destination = FlatOnOffInsurance

    let idName = "insurance_id"
    let protectionsName = "active_protection_list"

    let idTransformer = IdTransformer<Any>()
    let protectionsTransformer = ArrayTransformer(from: Any.self, transformer: FlatOnOffProtectionTransformer(), skipFailures: true)

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let idResult = dictionary[idName].map(idTransformer.transform(source:)) ?? .failure(.requirement)
        let protectionsResult = dictionary[protectionsName].map(protectionsTransformer.transform(source:)) ?? .failure(.requirement)

        var errors: [(String, TransformerError)] = []
        idResult.error.map { errors.append((idName, $0)) }
        protectionsResult.error.map { errors.append((protectionsName, $0)) }

        guard
            let id = idResult.value,
            let protections = protectionsResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                id: id,
                protections: protections
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let idResult = idTransformer.transform(destination: value.id)
        let protectionsResult = protectionsTransformer.transform(destination: value.protections)

        var errors: [(String, TransformerError)] = []
        idResult.error.map { errors.append((idName, $0)) }
        protectionsResult.error.map { errors.append((protectionsName, $0)) }

        guard
            let id = idResult.value,
            let protections = protectionsResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[idName] = id
        dictionary[protectionsName] = protections
        return .success(dictionary)
    }
}
