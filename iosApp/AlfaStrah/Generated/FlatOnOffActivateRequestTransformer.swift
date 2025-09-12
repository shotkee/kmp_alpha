// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct FlatOnOffActivateRequestTransformer: Transformer {
    typealias Source = Any
    typealias Destination = FlatOnOffActivateRequest

    let insuranceIdName = "insurance_id"
    let startDateName = "start_date"
    let endDateName = "end_date"

    let insuranceIdTransformer = IdTransformer<Any>()
    let startDateTransformer = DateTransformer<Any>(format: "yyyy-MM-dd", locale: AppLocale.currentLocale)
    let endDateTransformer = DateTransformer<Any>(format: "yyyy-MM-dd", locale: AppLocale.currentLocale)

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let insuranceIdResult = dictionary[insuranceIdName].map(insuranceIdTransformer.transform(source:)) ?? .failure(.requirement)
        let startDateResult = dictionary[startDateName].map(startDateTransformer.transform(source:)) ?? .failure(.requirement)
        let endDateResult = dictionary[endDateName].map(endDateTransformer.transform(source:)) ?? .failure(.requirement)

        var errors: [(String, TransformerError)] = []
        insuranceIdResult.error.map { errors.append((insuranceIdName, $0)) }
        startDateResult.error.map { errors.append((startDateName, $0)) }
        endDateResult.error.map { errors.append((endDateName, $0)) }

        guard
            let insuranceId = insuranceIdResult.value,
            let startDate = startDateResult.value,
            let endDate = endDateResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                insuranceId: insuranceId,
                startDate: startDate,
                endDate: endDate
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let insuranceIdResult = insuranceIdTransformer.transform(destination: value.insuranceId)
        let startDateResult = startDateTransformer.transform(destination: value.startDate)
        let endDateResult = endDateTransformer.transform(destination: value.endDate)

        var errors: [(String, TransformerError)] = []
        insuranceIdResult.error.map { errors.append((insuranceIdName, $0)) }
        startDateResult.error.map { errors.append((startDateName, $0)) }
        endDateResult.error.map { errors.append((endDateName, $0)) }

        guard
            let insuranceId = insuranceIdResult.value,
            let startDate = startDateResult.value,
            let endDate = endDateResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[insuranceIdName] = insuranceId
        dictionary[startDateName] = startDate
        dictionary[endDateName] = endDate
        return .success(dictionary)
    }
}
