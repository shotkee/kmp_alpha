// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct VzrOnOffInsuranceTransformer: Transformer {
    typealias Source = Any
    typealias Destination = VzrOnOffInsurance

    let insuranceIdName = "insurance_id"
    let activeTripListName = "active_trip_list"

    let insuranceIdTransformer = IdTransformer<Any>()
    let activeTripListTransformer = ArrayTransformer(from: Any.self, transformer: VzrOnOffTripTransformer(), skipFailures: true)

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let insuranceIdResult = dictionary[insuranceIdName].map(insuranceIdTransformer.transform(source:)) ?? .failure(.requirement)
        let activeTripListResult = dictionary[activeTripListName].map(activeTripListTransformer.transform(source:)) ?? .failure(.requirement)

        var errors: [(String, TransformerError)] = []
        insuranceIdResult.error.map { errors.append((insuranceIdName, $0)) }
        activeTripListResult.error.map { errors.append((activeTripListName, $0)) }

        guard
            let insuranceId = insuranceIdResult.value,
            let activeTripList = activeTripListResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                insuranceId: insuranceId,
                activeTripList: activeTripList
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let insuranceIdResult = insuranceIdTransformer.transform(destination: value.insuranceId)
        let activeTripListResult = activeTripListTransformer.transform(destination: value.activeTripList)

        var errors: [(String, TransformerError)] = []
        insuranceIdResult.error.map { errors.append((insuranceIdName, $0)) }
        activeTripListResult.error.map { errors.append((activeTripListName, $0)) }

        guard
            let insuranceId = insuranceIdResult.value,
            let activeTripList = activeTripListResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[insuranceIdName] = insuranceId
        dictionary[activeTripListName] = activeTripList
        return .success(dictionary)
    }
}
