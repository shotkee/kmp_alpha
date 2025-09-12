// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct PropertyRenewCalcResponseTransformer: Transformer {
    typealias Source = Any
    typealias Destination = PropertyRenewCalcResponse

    let priceName = "price"
    let startDateName = "start_date"
    let endDateName = "end_date"
    let accrualPointsName = "accrual_points"
    let maxSpendPointsName = "max_spend_points"
    let risksName = "risks"

    let priceTransformer = NumberTransformer<Any, Int>()
    let startDateTransformer = DateTransformer<Any>(format: "yyyy-MM-dd HH:mm:ss", locale: AppLocale.currentLocale)
    let endDateTransformer = DateTransformer<Any>(format: "yyyy-MM-dd HH:mm:ss", locale: AppLocale.currentLocale)
    let accrualPointsTransformer = NumberTransformer<Any, Int>()
    let maxSpendPointsTransformer = NumberTransformer<Any, Int>()
    let risksTransformer = ArrayTransformer(from: Any.self, transformer: InsuranceProlongationEstateRiskTransformer(), skipFailures: true)

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let priceResult = dictionary[priceName].map(priceTransformer.transform(source:)) ?? .failure(.requirement)
        let startDateResult = dictionary[startDateName].map(startDateTransformer.transform(source:)) ?? .failure(.requirement)
        let endDateResult = dictionary[endDateName].map(endDateTransformer.transform(source:)) ?? .failure(.requirement)
        let accrualPointsResult = dictionary[accrualPointsName].map(accrualPointsTransformer.transform(source:)) ?? .failure(.requirement)
        let maxSpendPointsResult = dictionary[maxSpendPointsName].map(maxSpendPointsTransformer.transform(source:)) ?? .failure(.requirement)
        let risksResult = dictionary[risksName].map(risksTransformer.transform(source:)) ?? .failure(.requirement)

        var errors: [(String, TransformerError)] = []
        priceResult.error.map { errors.append((priceName, $0)) }
        startDateResult.error.map { errors.append((startDateName, $0)) }
        endDateResult.error.map { errors.append((endDateName, $0)) }
        accrualPointsResult.error.map { errors.append((accrualPointsName, $0)) }
        maxSpendPointsResult.error.map { errors.append((maxSpendPointsName, $0)) }
        risksResult.error.map { errors.append((risksName, $0)) }

        guard
            let price = priceResult.value,
            let startDate = startDateResult.value,
            let endDate = endDateResult.value,
            let accrualPoints = accrualPointsResult.value,
            let maxSpendPoints = maxSpendPointsResult.value,
            let risks = risksResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                price: price,
                startDate: startDate,
                endDate: endDate,
                accrualPoints: accrualPoints,
                maxSpendPoints: maxSpendPoints,
                risks: risks
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let priceResult = priceTransformer.transform(destination: value.price)
        let startDateResult = startDateTransformer.transform(destination: value.startDate)
        let endDateResult = endDateTransformer.transform(destination: value.endDate)
        let accrualPointsResult = accrualPointsTransformer.transform(destination: value.accrualPoints)
        let maxSpendPointsResult = maxSpendPointsTransformer.transform(destination: value.maxSpendPoints)
        let risksResult = risksTransformer.transform(destination: value.risks)

        var errors: [(String, TransformerError)] = []
        priceResult.error.map { errors.append((priceName, $0)) }
        startDateResult.error.map { errors.append((startDateName, $0)) }
        endDateResult.error.map { errors.append((endDateName, $0)) }
        accrualPointsResult.error.map { errors.append((accrualPointsName, $0)) }
        maxSpendPointsResult.error.map { errors.append((maxSpendPointsName, $0)) }
        risksResult.error.map { errors.append((risksName, $0)) }

        guard
            let price = priceResult.value,
            let startDate = startDateResult.value,
            let endDate = endDateResult.value,
            let accrualPoints = accrualPointsResult.value,
            let maxSpendPoints = maxSpendPointsResult.value,
            let risks = risksResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[priceName] = price
        dictionary[startDateName] = startDate
        dictionary[endDateName] = endDate
        dictionary[accrualPointsName] = accrualPoints
        dictionary[maxSpendPointsName] = maxSpendPoints
        dictionary[risksName] = risks
        return .success(dictionary)
    }
}
