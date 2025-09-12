// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct DraftsCalculationsDataTransformer: Transformer {
    typealias Source = Any
    typealias Destination = DraftsCalculationsData

    let idName = "draft_id"
    let titleName = "calculation_title"
    let calculationNumberName = "calculation_number"
    let dateName = "calculation_date"
    let daysUntilDeleteName = "days_until_delete"
    let parametersName = "parameter_list"
    let priceName = "price"
    let urlName = "redirect_url"

    let idTransformer = NumberTransformer<Any, Int>()
    let titleTransformer = CastTransformer<Any, String>()
    let calculationNumberTransformer = CastTransformer<Any, String>()
    let dateTransformer = DateTransformer<Any>()
    let daysUntilDeleteTransformer = OptionalTransformer(transformer: CastTransformer<Any, String>())
    let parametersTransformer = ArrayTransformer(from: Any.self, transformer: FieldListTransformer(), skipFailures: true)
    let priceTransformer = OptionalTransformer(transformer: CastTransformer<Any, String>())
    let urlTransformer = OptionalTransformer(transformer: UrlTransformer<Any>())

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let idResult = dictionary[idName].map(idTransformer.transform(source:)) ?? .failure(.requirement)
        let titleResult = dictionary[titleName].map(titleTransformer.transform(source:)) ?? .failure(.requirement)
        let calculationNumberResult = dictionary[calculationNumberName].map(calculationNumberTransformer.transform(source:)) ?? .failure(.requirement)
        let dateResult = dictionary[dateName].map(dateTransformer.transform(source:)) ?? .failure(.requirement)
        let daysUntilDeleteResult = daysUntilDeleteTransformer.transform(source: dictionary[daysUntilDeleteName])
        let parametersResult = dictionary[parametersName].map(parametersTransformer.transform(source:)) ?? .failure(.requirement)
        let priceResult = priceTransformer.transform(source: dictionary[priceName])
        let urlResult = urlTransformer.transform(source: dictionary[urlName])

        var errors: [(String, TransformerError)] = []
        idResult.error.map { errors.append((idName, $0)) }
        titleResult.error.map { errors.append((titleName, $0)) }
        calculationNumberResult.error.map { errors.append((calculationNumberName, $0)) }
        dateResult.error.map { errors.append((dateName, $0)) }
        daysUntilDeleteResult.error.map { errors.append((daysUntilDeleteName, $0)) }
        parametersResult.error.map { errors.append((parametersName, $0)) }
        priceResult.error.map { errors.append((priceName, $0)) }
        urlResult.error.map { errors.append((urlName, $0)) }

        guard
            let id = idResult.value,
            let title = titleResult.value,
            let calculationNumber = calculationNumberResult.value,
            let date = dateResult.value,
            let daysUntilDelete = daysUntilDeleteResult.value,
            let parameters = parametersResult.value,
            let price = priceResult.value,
            let url = urlResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                id: id,
                title: title,
                calculationNumber: calculationNumber,
                date: date,
                daysUntilDelete: daysUntilDelete,
                parameters: parameters,
                price: price,
                url: url
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let idResult = idTransformer.transform(destination: value.id)
        let titleResult = titleTransformer.transform(destination: value.title)
        let calculationNumberResult = calculationNumberTransformer.transform(destination: value.calculationNumber)
        let dateResult = dateTransformer.transform(destination: value.date)
        let daysUntilDeleteResult = daysUntilDeleteTransformer.transform(destination: value.daysUntilDelete)
        let parametersResult = parametersTransformer.transform(destination: value.parameters)
        let priceResult = priceTransformer.transform(destination: value.price)
        let urlResult = urlTransformer.transform(destination: value.url)

        var errors: [(String, TransformerError)] = []
        idResult.error.map { errors.append((idName, $0)) }
        titleResult.error.map { errors.append((titleName, $0)) }
        calculationNumberResult.error.map { errors.append((calculationNumberName, $0)) }
        dateResult.error.map { errors.append((dateName, $0)) }
        daysUntilDeleteResult.error.map { errors.append((daysUntilDeleteName, $0)) }
        parametersResult.error.map { errors.append((parametersName, $0)) }
        priceResult.error.map { errors.append((priceName, $0)) }
        urlResult.error.map { errors.append((urlName, $0)) }

        guard
            let id = idResult.value,
            let title = titleResult.value,
            let calculationNumber = calculationNumberResult.value,
            let date = dateResult.value,
            let daysUntilDelete = daysUntilDeleteResult.value,
            let parameters = parametersResult.value,
            let price = priceResult.value,
            let url = urlResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[idName] = id
        dictionary[titleName] = title
        dictionary[calculationNumberName] = calculationNumber
        dictionary[dateName] = date
        dictionary[daysUntilDeleteName] = daysUntilDelete
        dictionary[parametersName] = parameters
        dictionary[priceName] = price
        dictionary[urlName] = url
        return .success(dictionary)
    }
}
