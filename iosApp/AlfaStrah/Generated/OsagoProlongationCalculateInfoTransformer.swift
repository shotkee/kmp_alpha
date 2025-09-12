// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct OsagoProlongationCalculateInfoTransformer: Transformer {
    typealias Source = Any
    typealias Destination = OsagoProlongationCalculateInfo

    let sumName = "sum"
    let startDateName = "start_date"
    let endDateName = "end_date"
    let carMarkName = "car_mark"
    let carRegistrationNumberName = "car_regnum"
    let carVinName = "car_vin"

    let sumTransformer = NumberTransformer<Any, Double>()
    let startDateTransformer = DateTransformer<Any>(format: "yyyy-MM-dd", locale: AppLocale.currentLocale)
    let endDateTransformer = DateTransformer<Any>(format: "yyyy-MM-dd", locale: AppLocale.currentLocale)
    let carMarkTransformer = OptionalTransformer(transformer: CastTransformer<Any, String>())
    let carRegistrationNumberTransformer = OptionalTransformer(transformer: CastTransformer<Any, String>())
    let carVinTransformer = OptionalTransformer(transformer: CastTransformer<Any, String>())

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let sumResult = dictionary[sumName].map(sumTransformer.transform(source:)) ?? .failure(.requirement)
        let startDateResult = dictionary[startDateName].map(startDateTransformer.transform(source:)) ?? .failure(.requirement)
        let endDateResult = dictionary[endDateName].map(endDateTransformer.transform(source:)) ?? .failure(.requirement)
        let carMarkResult = carMarkTransformer.transform(source: dictionary[carMarkName])
        let carRegistrationNumberResult = carRegistrationNumberTransformer.transform(source: dictionary[carRegistrationNumberName])
        let carVinResult = carVinTransformer.transform(source: dictionary[carVinName])

        var errors: [(String, TransformerError)] = []
        sumResult.error.map { errors.append((sumName, $0)) }
        startDateResult.error.map { errors.append((startDateName, $0)) }
        endDateResult.error.map { errors.append((endDateName, $0)) }
        carMarkResult.error.map { errors.append((carMarkName, $0)) }
        carRegistrationNumberResult.error.map { errors.append((carRegistrationNumberName, $0)) }
        carVinResult.error.map { errors.append((carVinName, $0)) }

        guard
            let sum = sumResult.value,
            let startDate = startDateResult.value,
            let endDate = endDateResult.value,
            let carMark = carMarkResult.value,
            let carRegistrationNumber = carRegistrationNumberResult.value,
            let carVin = carVinResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                sum: sum,
                startDate: startDate,
                endDate: endDate,
                carMark: carMark,
                carRegistrationNumber: carRegistrationNumber,
                carVin: carVin
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let sumResult = sumTransformer.transform(destination: value.sum)
        let startDateResult = startDateTransformer.transform(destination: value.startDate)
        let endDateResult = endDateTransformer.transform(destination: value.endDate)
        let carMarkResult = carMarkTransformer.transform(destination: value.carMark)
        let carRegistrationNumberResult = carRegistrationNumberTransformer.transform(destination: value.carRegistrationNumber)
        let carVinResult = carVinTransformer.transform(destination: value.carVin)

        var errors: [(String, TransformerError)] = []
        sumResult.error.map { errors.append((sumName, $0)) }
        startDateResult.error.map { errors.append((startDateName, $0)) }
        endDateResult.error.map { errors.append((endDateName, $0)) }
        carMarkResult.error.map { errors.append((carMarkName, $0)) }
        carRegistrationNumberResult.error.map { errors.append((carRegistrationNumberName, $0)) }
        carVinResult.error.map { errors.append((carVinName, $0)) }

        guard
            let sum = sumResult.value,
            let startDate = startDateResult.value,
            let endDate = endDateResult.value,
            let carMark = carMarkResult.value,
            let carRegistrationNumber = carRegistrationNumberResult.value,
            let carVin = carVinResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[sumName] = sum
        dictionary[startDateName] = startDate
        dictionary[endDateName] = endDate
        dictionary[carMarkName] = carMark
        dictionary[carRegistrationNumberName] = carRegistrationNumber
        dictionary[carVinName] = carVin
        return .success(dictionary)
    }
}
