// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct FlatOnOffPurchaseItemTransformer: Transformer {
    typealias Source = Any
    typealias Destination = FlatOnOffPurchaseItem

    let idName = "id"
    let titleName = "title"
    let priceName = "price"
    let daysName = "days"
    let successTextName = "success_text"
    let contractUrlName = "contract_url"
    let insuranceUrlName = "insurance_url"

    let idTransformer = IdTransformer<Any>()
    let titleTransformer = CastTransformer<Any, String>()
    let priceTransformer = NumberTransformer<Any, Double>()
    let daysTransformer = NumberTransformer<Any, Int>()
    let successTextTransformer = CastTransformer<Any, String>()
    let contractUrlTransformer = UrlTransformer<Any>()
    let insuranceUrlTransformer = UrlTransformer<Any>()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let idResult = dictionary[idName].map(idTransformer.transform(source:)) ?? .failure(.requirement)
        let titleResult = dictionary[titleName].map(titleTransformer.transform(source:)) ?? .failure(.requirement)
        let priceResult = dictionary[priceName].map(priceTransformer.transform(source:)) ?? .failure(.requirement)
        let daysResult = dictionary[daysName].map(daysTransformer.transform(source:)) ?? .failure(.requirement)
        let successTextResult = dictionary[successTextName].map(successTextTransformer.transform(source:)) ?? .failure(.requirement)
        let contractUrlResult = dictionary[contractUrlName].map(contractUrlTransformer.transform(source:)) ?? .failure(.requirement)
        let insuranceUrlResult = dictionary[insuranceUrlName].map(insuranceUrlTransformer.transform(source:)) ?? .failure(.requirement)

        var errors: [(String, TransformerError)] = []
        idResult.error.map { errors.append((idName, $0)) }
        titleResult.error.map { errors.append((titleName, $0)) }
        priceResult.error.map { errors.append((priceName, $0)) }
        daysResult.error.map { errors.append((daysName, $0)) }
        successTextResult.error.map { errors.append((successTextName, $0)) }
        contractUrlResult.error.map { errors.append((contractUrlName, $0)) }
        insuranceUrlResult.error.map { errors.append((insuranceUrlName, $0)) }

        guard
            let id = idResult.value,
            let title = titleResult.value,
            let price = priceResult.value,
            let days = daysResult.value,
            let successText = successTextResult.value,
            let contractUrl = contractUrlResult.value,
            let insuranceUrl = insuranceUrlResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                id: id,
                title: title,
                price: price,
                days: days,
                successText: successText,
                contractUrl: contractUrl,
                insuranceUrl: insuranceUrl
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let idResult = idTransformer.transform(destination: value.id)
        let titleResult = titleTransformer.transform(destination: value.title)
        let priceResult = priceTransformer.transform(destination: value.price)
        let daysResult = daysTransformer.transform(destination: value.days)
        let successTextResult = successTextTransformer.transform(destination: value.successText)
        let contractUrlResult = contractUrlTransformer.transform(destination: value.contractUrl)
        let insuranceUrlResult = insuranceUrlTransformer.transform(destination: value.insuranceUrl)

        var errors: [(String, TransformerError)] = []
        idResult.error.map { errors.append((idName, $0)) }
        titleResult.error.map { errors.append((titleName, $0)) }
        priceResult.error.map { errors.append((priceName, $0)) }
        daysResult.error.map { errors.append((daysName, $0)) }
        successTextResult.error.map { errors.append((successTextName, $0)) }
        contractUrlResult.error.map { errors.append((contractUrlName, $0)) }
        insuranceUrlResult.error.map { errors.append((insuranceUrlName, $0)) }

        guard
            let id = idResult.value,
            let title = titleResult.value,
            let price = priceResult.value,
            let days = daysResult.value,
            let successText = successTextResult.value,
            let contractUrl = contractUrlResult.value,
            let insuranceUrl = insuranceUrlResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[idName] = id
        dictionary[titleName] = title
        dictionary[priceName] = price
        dictionary[daysName] = days
        dictionary[successTextName] = successText
        dictionary[contractUrlName] = contractUrl
        dictionary[insuranceUrlName] = insuranceUrl
        return .success(dictionary)
    }
}
