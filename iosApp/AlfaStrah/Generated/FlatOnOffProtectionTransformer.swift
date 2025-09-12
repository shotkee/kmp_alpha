// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct FlatOnOffProtectionTransformer: Transformer {
    typealias Source = Any
    typealias Destination = FlatOnOffProtection

    let idName = "id"
    let startDateName = "start_date"
    let endDateName = "end_date"
    let daysName = "days"
    let statusName = "status"

    let idTransformer = IdTransformer<Any>()
    let startDateTransformer = DateTransformer<Any>(format: "yyyy-MM-dd", locale: AppLocale.currentLocale)
    let endDateTransformer = DateTransformer<Any>(format: "yyyy-MM-dd", locale: AppLocale.currentLocale)
    let daysTransformer = NumberTransformer<Any, Int>()
    let statusTransformer = FlatOnOffProtectionStatusTransformer()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let idResult = dictionary[idName].map(idTransformer.transform(source:)) ?? .failure(.requirement)
        let startDateResult = dictionary[startDateName].map(startDateTransformer.transform(source:)) ?? .failure(.requirement)
        let endDateResult = dictionary[endDateName].map(endDateTransformer.transform(source:)) ?? .failure(.requirement)
        let daysResult = dictionary[daysName].map(daysTransformer.transform(source:)) ?? .failure(.requirement)
        let statusResult = dictionary[statusName].map(statusTransformer.transform(source:)) ?? .failure(.requirement)

        var errors: [(String, TransformerError)] = []
        idResult.error.map { errors.append((idName, $0)) }
        startDateResult.error.map { errors.append((startDateName, $0)) }
        endDateResult.error.map { errors.append((endDateName, $0)) }
        daysResult.error.map { errors.append((daysName, $0)) }
        statusResult.error.map { errors.append((statusName, $0)) }

        guard
            let id = idResult.value,
            let startDate = startDateResult.value,
            let endDate = endDateResult.value,
            let days = daysResult.value,
            let status = statusResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                id: id,
                startDate: startDate,
                endDate: endDate,
                days: days,
                status: status
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let idResult = idTransformer.transform(destination: value.id)
        let startDateResult = startDateTransformer.transform(destination: value.startDate)
        let endDateResult = endDateTransformer.transform(destination: value.endDate)
        let daysResult = daysTransformer.transform(destination: value.days)
        let statusResult = statusTransformer.transform(destination: value.status)

        var errors: [(String, TransformerError)] = []
        idResult.error.map { errors.append((idName, $0)) }
        startDateResult.error.map { errors.append((startDateName, $0)) }
        endDateResult.error.map { errors.append((endDateName, $0)) }
        daysResult.error.map { errors.append((daysName, $0)) }
        statusResult.error.map { errors.append((statusName, $0)) }

        guard
            let id = idResult.value,
            let startDate = startDateResult.value,
            let endDate = endDateResult.value,
            let days = daysResult.value,
            let status = statusResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[idName] = id
        dictionary[startDateName] = startDate
        dictionary[endDateName] = endDate
        dictionary[daysName] = days
        dictionary[statusName] = status
        return .success(dictionary)
    }
}
