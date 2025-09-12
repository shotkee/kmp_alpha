// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct ManageAppointmentRequestTransformer: Transformer {
    typealias Source = Any
    typealias Destination = ManageAppointmentRequest

    let intervalIdName = "interval_id"
    let insuranceIdName = "insurance_id"

    let intervalIdTransformer = OptionalTransformer(transformer: CastTransformer<Any, String>())
    let insuranceIdTransformer = OptionalTransformer(transformer: CastTransformer<Any, String>())

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let intervalIdResult = intervalIdTransformer.transform(source: dictionary[intervalIdName])
        let insuranceIdResult = insuranceIdTransformer.transform(source: dictionary[insuranceIdName])

        var errors: [(String, TransformerError)] = []
        intervalIdResult.error.map { errors.append((intervalIdName, $0)) }
        insuranceIdResult.error.map { errors.append((insuranceIdName, $0)) }

        guard
            let intervalId = intervalIdResult.value,
            let insuranceId = insuranceIdResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                intervalId: intervalId,
                insuranceId: insuranceId
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let intervalIdResult = intervalIdTransformer.transform(destination: value.intervalId)
        let insuranceIdResult = insuranceIdTransformer.transform(destination: value.insuranceId)

        var errors: [(String, TransformerError)] = []
        intervalIdResult.error.map { errors.append((intervalIdName, $0)) }
        insuranceIdResult.error.map { errors.append((insuranceIdName, $0)) }

        guard
            let intervalId = intervalIdResult.value,
            let insuranceId = insuranceIdResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[intervalIdName] = intervalId
        dictionary[insuranceIdName] = insuranceId
        return .success(dictionary)
    }
}
