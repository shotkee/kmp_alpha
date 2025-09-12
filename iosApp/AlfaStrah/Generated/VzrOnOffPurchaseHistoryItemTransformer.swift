// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct VzrOnOffPurchaseHistoryItemTransformer: Transformer {
    typealias Source = Any
    typealias Destination = VzrOnOffPurchaseHistoryItem

    let purchaseDateName = "date_buy"
    let titleName = "title"
    let currencyName = "currency"
    let currencyPriceName = "currency_price"
    let daysName = "days"

    let purchaseDateTransformer = DateTransformer<Any>(format: "yyyy-MM-dd", locale: AppLocale.currentLocale)
    let titleTransformer = CastTransformer<Any, String>()
    let currencyTransformer = CastTransformer<Any, String>()
    let currencyPriceTransformer = NumberTransformer<Any, Double>()
    let daysTransformer = NumberTransformer<Any, Int>()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let purchaseDateResult = dictionary[purchaseDateName].map(purchaseDateTransformer.transform(source:)) ?? .failure(.requirement)
        let titleResult = dictionary[titleName].map(titleTransformer.transform(source:)) ?? .failure(.requirement)
        let currencyResult = dictionary[currencyName].map(currencyTransformer.transform(source:)) ?? .failure(.requirement)
        let currencyPriceResult = dictionary[currencyPriceName].map(currencyPriceTransformer.transform(source:)) ?? .failure(.requirement)
        let daysResult = dictionary[daysName].map(daysTransformer.transform(source:)) ?? .failure(.requirement)

        var errors: [(String, TransformerError)] = []
        purchaseDateResult.error.map { errors.append((purchaseDateName, $0)) }
        titleResult.error.map { errors.append((titleName, $0)) }
        currencyResult.error.map { errors.append((currencyName, $0)) }
        currencyPriceResult.error.map { errors.append((currencyPriceName, $0)) }
        daysResult.error.map { errors.append((daysName, $0)) }

        guard
            let purchaseDate = purchaseDateResult.value,
            let title = titleResult.value,
            let currency = currencyResult.value,
            let currencyPrice = currencyPriceResult.value,
            let days = daysResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                purchaseDate: purchaseDate,
                title: title,
                currency: currency,
                currencyPrice: currencyPrice,
                days: days
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let purchaseDateResult = purchaseDateTransformer.transform(destination: value.purchaseDate)
        let titleResult = titleTransformer.transform(destination: value.title)
        let currencyResult = currencyTransformer.transform(destination: value.currency)
        let currencyPriceResult = currencyPriceTransformer.transform(destination: value.currencyPrice)
        let daysResult = daysTransformer.transform(destination: value.days)

        var errors: [(String, TransformerError)] = []
        purchaseDateResult.error.map { errors.append((purchaseDateName, $0)) }
        titleResult.error.map { errors.append((titleName, $0)) }
        currencyResult.error.map { errors.append((currencyName, $0)) }
        currencyPriceResult.error.map { errors.append((currencyPriceName, $0)) }
        daysResult.error.map { errors.append((daysName, $0)) }

        guard
            let purchaseDate = purchaseDateResult.value,
            let title = titleResult.value,
            let currency = currencyResult.value,
            let currencyPrice = currencyPriceResult.value,
            let days = daysResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[purchaseDateName] = purchaseDate
        dictionary[titleName] = title
        dictionary[currencyName] = currency
        dictionary[currencyPriceName] = currencyPrice
        dictionary[daysName] = days
        return .success(dictionary)
    }
}
