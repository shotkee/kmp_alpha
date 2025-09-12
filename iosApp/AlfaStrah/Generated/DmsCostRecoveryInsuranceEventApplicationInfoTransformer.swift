// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct DmsCostRecoveryInsuranceEventApplicationInfoTransformer: Transformer {
    typealias Source = Any
    typealias Destination = DmsCostRecoveryInsuranceEventApplicationInfo

    let countryName = "country"
    let dateName = "date"
    let medicalServiceName = "service"
    let reasonName = "reason"
    let expensesAmountName = "cost"
    let currencyName = "currency"

    let countryTransformer = CastTransformer<Any, String>()
    let dateTransformer = DateTransformer<Any>(format: "yyyy-MM-dd")
    let medicalServiceTransformer = CastTransformer<Any, String>()
    let reasonTransformer = CastTransformer<Any, String>()
    let expensesAmountTransformer = CastTransformer<Any, String>()
    let currencyTransformer = CastTransformer<Any, String>()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let countryResult = dictionary[countryName].map(countryTransformer.transform(source:)) ?? .failure(.requirement)
        let dateResult = dictionary[dateName].map(dateTransformer.transform(source:)) ?? .failure(.requirement)
        let medicalServiceResult = dictionary[medicalServiceName].map(medicalServiceTransformer.transform(source:)) ?? .failure(.requirement)
        let reasonResult = dictionary[reasonName].map(reasonTransformer.transform(source:)) ?? .failure(.requirement)
        let expensesAmountResult = dictionary[expensesAmountName].map(expensesAmountTransformer.transform(source:)) ?? .failure(.requirement)
        let currencyResult = dictionary[currencyName].map(currencyTransformer.transform(source:)) ?? .failure(.requirement)

        var errors: [(String, TransformerError)] = []
        countryResult.error.map { errors.append((countryName, $0)) }
        dateResult.error.map { errors.append((dateName, $0)) }
        medicalServiceResult.error.map { errors.append((medicalServiceName, $0)) }
        reasonResult.error.map { errors.append((reasonName, $0)) }
        expensesAmountResult.error.map { errors.append((expensesAmountName, $0)) }
        currencyResult.error.map { errors.append((currencyName, $0)) }

        guard
            let country = countryResult.value,
            let date = dateResult.value,
            let medicalService = medicalServiceResult.value,
            let reason = reasonResult.value,
            let expensesAmount = expensesAmountResult.value,
            let currency = currencyResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                country: country,
                date: date,
                medicalService: medicalService,
                reason: reason,
                expensesAmount: expensesAmount,
                currency: currency
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let countryResult = countryTransformer.transform(destination: value.country)
        let dateResult = dateTransformer.transform(destination: value.date)
        let medicalServiceResult = medicalServiceTransformer.transform(destination: value.medicalService)
        let reasonResult = reasonTransformer.transform(destination: value.reason)
        let expensesAmountResult = expensesAmountTransformer.transform(destination: value.expensesAmount)
        let currencyResult = currencyTransformer.transform(destination: value.currency)

        var errors: [(String, TransformerError)] = []
        countryResult.error.map { errors.append((countryName, $0)) }
        dateResult.error.map { errors.append((dateName, $0)) }
        medicalServiceResult.error.map { errors.append((medicalServiceName, $0)) }
        reasonResult.error.map { errors.append((reasonName, $0)) }
        expensesAmountResult.error.map { errors.append((expensesAmountName, $0)) }
        currencyResult.error.map { errors.append((currencyName, $0)) }

        guard
            let country = countryResult.value,
            let date = dateResult.value,
            let medicalService = medicalServiceResult.value,
            let reason = reasonResult.value,
            let expensesAmount = expensesAmountResult.value,
            let currency = currencyResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[countryName] = country
        dictionary[dateName] = date
        dictionary[medicalServiceName] = medicalService
        dictionary[reasonName] = reason
        dictionary[expensesAmountName] = expensesAmount
        dictionary[currencyName] = currency
        return .success(dictionary)
    }
}
