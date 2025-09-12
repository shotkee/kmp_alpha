// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct VzrOnOffPurchaseItemTransformer: Transformer {
    typealias Source = Any
    typealias Destination = VzrOnOffPurchaseItem

    let idName = "id"
    let titleName = "title"
    let currencyName = "currency"
    let currencyPriceName = "currency_price"
    let daysName = "days"
    let ofertaUrlName = "oferta_url"
    let successTextName = "success_text"

    let idTransformer = IdTransformer<Any>()
    let titleTransformer = CastTransformer<Any, String>()
    let currencyTransformer = CastTransformer<Any, String>()
    let currencyPriceTransformer = NumberTransformer<Any, Double>()
    let daysTransformer = NumberTransformer<Any, Int>()
    let ofertaUrlTransformer = CastTransformer<Any, String>()
    let successTextTransformer = CastTransformer<Any, String>()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let idResult = dictionary[idName].map(idTransformer.transform(source:)) ?? .failure(.requirement)
        let titleResult = dictionary[titleName].map(titleTransformer.transform(source:)) ?? .failure(.requirement)
        let currencyResult = dictionary[currencyName].map(currencyTransformer.transform(source:)) ?? .failure(.requirement)
        let currencyPriceResult = dictionary[currencyPriceName].map(currencyPriceTransformer.transform(source:)) ?? .failure(.requirement)
        let daysResult = dictionary[daysName].map(daysTransformer.transform(source:)) ?? .failure(.requirement)
        let ofertaUrlResult = dictionary[ofertaUrlName].map(ofertaUrlTransformer.transform(source:)) ?? .failure(.requirement)
        let successTextResult = dictionary[successTextName].map(successTextTransformer.transform(source:)) ?? .failure(.requirement)

        var errors: [(String, TransformerError)] = []
        idResult.error.map { errors.append((idName, $0)) }
        titleResult.error.map { errors.append((titleName, $0)) }
        currencyResult.error.map { errors.append((currencyName, $0)) }
        currencyPriceResult.error.map { errors.append((currencyPriceName, $0)) }
        daysResult.error.map { errors.append((daysName, $0)) }
        ofertaUrlResult.error.map { errors.append((ofertaUrlName, $0)) }
        successTextResult.error.map { errors.append((successTextName, $0)) }

        guard
            let id = idResult.value,
            let title = titleResult.value,
            let currency = currencyResult.value,
            let currencyPrice = currencyPriceResult.value,
            let days = daysResult.value,
            let ofertaUrl = ofertaUrlResult.value,
            let successText = successTextResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                id: id,
                title: title,
                currency: currency,
                currencyPrice: currencyPrice,
                days: days,
                ofertaUrl: ofertaUrl,
                successText: successText
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let idResult = idTransformer.transform(destination: value.id)
        let titleResult = titleTransformer.transform(destination: value.title)
        let currencyResult = currencyTransformer.transform(destination: value.currency)
        let currencyPriceResult = currencyPriceTransformer.transform(destination: value.currencyPrice)
        let daysResult = daysTransformer.transform(destination: value.days)
        let ofertaUrlResult = ofertaUrlTransformer.transform(destination: value.ofertaUrl)
        let successTextResult = successTextTransformer.transform(destination: value.successText)

        var errors: [(String, TransformerError)] = []
        idResult.error.map { errors.append((idName, $0)) }
        titleResult.error.map { errors.append((titleName, $0)) }
        currencyResult.error.map { errors.append((currencyName, $0)) }
        currencyPriceResult.error.map { errors.append((currencyPriceName, $0)) }
        daysResult.error.map { errors.append((daysName, $0)) }
        ofertaUrlResult.error.map { errors.append((ofertaUrlName, $0)) }
        successTextResult.error.map { errors.append((successTextName, $0)) }

        guard
            let id = idResult.value,
            let title = titleResult.value,
            let currency = currencyResult.value,
            let currencyPrice = currencyPriceResult.value,
            let days = daysResult.value,
            let ofertaUrl = ofertaUrlResult.value,
            let successText = successTextResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[idName] = id
        dictionary[titleName] = title
        dictionary[currencyName] = currency
        dictionary[currencyPriceName] = currencyPrice
        dictionary[daysName] = days
        dictionary[ofertaUrlName] = ofertaUrl
        dictionary[successTextName] = successText
        return .success(dictionary)
    }
}
