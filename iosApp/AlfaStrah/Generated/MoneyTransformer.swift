// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct MoneyTransformer: Transformer {
    typealias Source = Any
    typealias Destination = Money

    let currencyName = "currency"
    let amountName = "amount"

    let currencyTransformer = CastTransformer<Any, String>()
    let amountTransformer = NumberTransformer<Any, Int64>()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let currencyResult = dictionary[currencyName].map(currencyTransformer.transform(source:)) ?? .failure(.requirement)
        let amountResult = dictionary[amountName].map(amountTransformer.transform(source:)) ?? .failure(.requirement)

        var errors: [(String, TransformerError)] = []
        currencyResult.error.map { errors.append((currencyName, $0)) }
        amountResult.error.map { errors.append((amountName, $0)) }

        guard
            let currency = currencyResult.value,
            let amount = amountResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                currency: currency,
                amount: amount
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let currencyResult = currencyTransformer.transform(destination: value.currency)
        let amountResult = amountTransformer.transform(destination: value.amount)

        var errors: [(String, TransformerError)] = []
        currencyResult.error.map { errors.append((currencyName, $0)) }
        amountResult.error.map { errors.append((amountName, $0)) }

        guard
            let currency = currencyResult.value,
            let amount = amountResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[currencyName] = currency
        dictionary[amountName] = amount
        return .success(dictionary)
    }
}
