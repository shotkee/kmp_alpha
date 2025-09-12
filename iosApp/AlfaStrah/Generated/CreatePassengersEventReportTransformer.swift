// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct CreatePassengersEventReportTransformer: Transformer {
    typealias Source = Any
    typealias Destination = CreatePassengersEventReport

    let insuranceIdName = "insurance_id"
    let riskValuesName = "risks"

    let insuranceIdTransformer = CastTransformer<Any, String>()
    let riskValuesTransformer = ArrayTransformer(from: Any.self, transformer: RiskValueTransformer(), skipFailures: true)

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let insuranceIdResult = dictionary[insuranceIdName].map(insuranceIdTransformer.transform(source:)) ?? .failure(.requirement)
        let riskValuesResult = dictionary[riskValuesName].map(riskValuesTransformer.transform(source:)) ?? .failure(.requirement)

        var errors: [(String, TransformerError)] = []
        insuranceIdResult.error.map { errors.append((insuranceIdName, $0)) }
        riskValuesResult.error.map { errors.append((riskValuesName, $0)) }

        guard
            let insuranceId = insuranceIdResult.value,
            let riskValues = riskValuesResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                insuranceId: insuranceId,
                riskValues: riskValues
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let insuranceIdResult = insuranceIdTransformer.transform(destination: value.insuranceId)
        let riskValuesResult = riskValuesTransformer.transform(destination: value.riskValues)

        var errors: [(String, TransformerError)] = []
        insuranceIdResult.error.map { errors.append((insuranceIdName, $0)) }
        riskValuesResult.error.map { errors.append((riskValuesName, $0)) }

        guard
            let insuranceId = insuranceIdResult.value,
            let riskValues = riskValuesResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[insuranceIdName] = insuranceId
        dictionary[riskValuesName] = riskValues
        return .success(dictionary)
    }
}
