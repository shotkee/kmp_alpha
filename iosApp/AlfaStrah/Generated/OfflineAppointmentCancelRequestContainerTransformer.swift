// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct OfflineAppointmentCancelRequestContainerTransformer: Transformer {
    typealias Source = Any
    typealias Destination = OfflineAppointmentCancelRequestContainer

    let avisIdName = "id"
    let insuranceIdName = "insurance_id"

    let avisIdTransformer = NumberTransformer<Any, Int>()
    let insuranceIdTransformer = CastTransformer<Any, String>()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let avisIdResult = dictionary[avisIdName].map(avisIdTransformer.transform(source:)) ?? .failure(.requirement)
        let insuranceIdResult = dictionary[insuranceIdName].map(insuranceIdTransformer.transform(source:)) ?? .failure(.requirement)

        var errors: [(String, TransformerError)] = []
        avisIdResult.error.map { errors.append((avisIdName, $0)) }
        insuranceIdResult.error.map { errors.append((insuranceIdName, $0)) }

        guard
            let avisId = avisIdResult.value,
            let insuranceId = insuranceIdResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                avisId: avisId,
                insuranceId: insuranceId
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let avisIdResult = avisIdTransformer.transform(destination: value.avisId)
        let insuranceIdResult = insuranceIdTransformer.transform(destination: value.insuranceId)

        var errors: [(String, TransformerError)] = []
        avisIdResult.error.map { errors.append((avisIdName, $0)) }
        insuranceIdResult.error.map { errors.append((insuranceIdName, $0)) }

        guard
            let avisId = avisIdResult.value,
            let insuranceId = insuranceIdResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[avisIdName] = avisId
        dictionary[insuranceIdName] = insuranceId
        return .success(dictionary)
    }
}
