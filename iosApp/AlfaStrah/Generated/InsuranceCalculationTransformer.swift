// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct InsuranceCalculationTransformer: Transformer {
    typealias Source = Any
    typealias Destination = InsuranceCalculation

    let priceName = "price"
    let maxSpendPointsName = "max_spend_points"
    let accrualPointsName = "accrual_points"
    let startDateName = "date_start"
    let endDateName = "date_end"

    let priceTransformer = NumberTransformer<Any, Double>()
    let maxSpendPointsTransformer = NumberTransformer<Any, Int>()
    let accrualPointsTransformer = NumberTransformer<Any, Int>()
    let startDateTransformer = OptionalTransformer(transformer: DateTransformer<Any>(format: "yyyy-MM-dd HH:mm:ss", locale: AppLocale.currentLocale))
    let endDateTransformer = OptionalTransformer(transformer: DateTransformer<Any>(format: "yyyy-MM-dd HH:mm:ss", locale: AppLocale.currentLocale))

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let priceResult = dictionary[priceName].map(priceTransformer.transform(source:)) ?? .failure(.requirement)
        let maxSpendPointsResult = dictionary[maxSpendPointsName].map(maxSpendPointsTransformer.transform(source:)) ?? .failure(.requirement)
        let accrualPointsResult = dictionary[accrualPointsName].map(accrualPointsTransformer.transform(source:)) ?? .failure(.requirement)
        let startDateResult = startDateTransformer.transform(source: dictionary[startDateName])
        let endDateResult = endDateTransformer.transform(source: dictionary[endDateName])

        var errors: [(String, TransformerError)] = []
        priceResult.error.map { errors.append((priceName, $0)) }
        maxSpendPointsResult.error.map { errors.append((maxSpendPointsName, $0)) }
        accrualPointsResult.error.map { errors.append((accrualPointsName, $0)) }
        startDateResult.error.map { errors.append((startDateName, $0)) }
        endDateResult.error.map { errors.append((endDateName, $0)) }

        guard
            let price = priceResult.value,
            let maxSpendPoints = maxSpendPointsResult.value,
            let accrualPoints = accrualPointsResult.value,
            let startDate = startDateResult.value,
            let endDate = endDateResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                price: price,
                maxSpendPoints: maxSpendPoints,
                accrualPoints: accrualPoints,
                startDate: startDate,
                endDate: endDate
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let priceResult = priceTransformer.transform(destination: value.price)
        let maxSpendPointsResult = maxSpendPointsTransformer.transform(destination: value.maxSpendPoints)
        let accrualPointsResult = accrualPointsTransformer.transform(destination: value.accrualPoints)
        let startDateResult = startDateTransformer.transform(destination: value.startDate)
        let endDateResult = endDateTransformer.transform(destination: value.endDate)

        var errors: [(String, TransformerError)] = []
        priceResult.error.map { errors.append((priceName, $0)) }
        maxSpendPointsResult.error.map { errors.append((maxSpendPointsName, $0)) }
        accrualPointsResult.error.map { errors.append((accrualPointsName, $0)) }
        startDateResult.error.map { errors.append((startDateName, $0)) }
        endDateResult.error.map { errors.append((endDateName, $0)) }

        guard
            let price = priceResult.value,
            let maxSpendPoints = maxSpendPointsResult.value,
            let accrualPoints = accrualPointsResult.value,
            let startDate = startDateResult.value,
            let endDate = endDateResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[priceName] = price
        dictionary[maxSpendPointsName] = maxSpendPoints
        dictionary[accrualPointsName] = accrualPoints
        dictionary[startDateName] = startDate
        dictionary[endDateName] = endDate
        return .success(dictionary)
    }
}
