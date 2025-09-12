// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct InsuranceCategoryTransformer: Transformer {
    typealias Source = Any
    typealias Destination = InsuranceCategory

    let idName = "id"
    let titleName = "title"
    let termsURLName = "terms_url"
    let sortPriorityName = "sort_priority"
    let daysLeftName = "days_left"
    let productIdsName = "product_id_list"
    let kindName = "type"
    let subtitleName = "subtitle"

    let idTransformer = IdTransformer<Any>()
    let titleTransformer = CastTransformer<Any, String>()
    let termsURLTransformer = OptionalTransformer(transformer: UrlTransformer<Any>())
    let sortPriorityTransformer = NumberTransformer<Any, Int>()
    let daysLeftTransformer = NumberTransformer<Any, Int>()
    let productIdsTransformer = ArrayTransformer(from: Any.self, transformer: CastTransformer<Any, String>(), skipFailures: true)
    let kindTransformer = InsuranceCategoryCategoryKindTransformer()
    let subtitleTransformer = CastTransformer<Any, String>()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let idResult = dictionary[idName].map(idTransformer.transform(source:)) ?? .failure(.requirement)
        let titleResult = dictionary[titleName].map(titleTransformer.transform(source:)) ?? .failure(.requirement)
        let termsURLResult = termsURLTransformer.transform(source: dictionary[termsURLName])
        let sortPriorityResult = dictionary[sortPriorityName].map(sortPriorityTransformer.transform(source:)) ?? .failure(.requirement)
        let daysLeftResult = dictionary[daysLeftName].map(daysLeftTransformer.transform(source:)) ?? .failure(.requirement)
        let productIdsResult = dictionary[productIdsName].map(productIdsTransformer.transform(source:)) ?? .failure(.requirement)
        let kindResult = dictionary[kindName].map(kindTransformer.transform(source:)) ?? .failure(.requirement)
        let subtitleResult = dictionary[subtitleName].map(subtitleTransformer.transform(source:)) ?? .failure(.requirement)

        var errors: [(String, TransformerError)] = []
        idResult.error.map { errors.append((idName, $0)) }
        titleResult.error.map { errors.append((titleName, $0)) }
        termsURLResult.error.map { errors.append((termsURLName, $0)) }
        sortPriorityResult.error.map { errors.append((sortPriorityName, $0)) }
        daysLeftResult.error.map { errors.append((daysLeftName, $0)) }
        productIdsResult.error.map { errors.append((productIdsName, $0)) }
        kindResult.error.map { errors.append((kindName, $0)) }
        subtitleResult.error.map { errors.append((subtitleName, $0)) }

        guard
            let id = idResult.value,
            let title = titleResult.value,
            let termsURL = termsURLResult.value,
            let sortPriority = sortPriorityResult.value,
            let daysLeft = daysLeftResult.value,
            let productIds = productIdsResult.value,
            let kind = kindResult.value,
            let subtitle = subtitleResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                id: id,
                title: title,
                termsURL: termsURL,
                sortPriority: sortPriority,
                daysLeft: daysLeft,
                productIds: productIds,
                kind: kind,
                subtitle: subtitle
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let idResult = idTransformer.transform(destination: value.id)
        let titleResult = titleTransformer.transform(destination: value.title)
        let termsURLResult = termsURLTransformer.transform(destination: value.termsURL)
        let sortPriorityResult = sortPriorityTransformer.transform(destination: value.sortPriority)
        let daysLeftResult = daysLeftTransformer.transform(destination: value.daysLeft)
        let productIdsResult = productIdsTransformer.transform(destination: value.productIds)
        let kindResult = kindTransformer.transform(destination: value.kind)
        let subtitleResult = subtitleTransformer.transform(destination: value.subtitle)

        var errors: [(String, TransformerError)] = []
        idResult.error.map { errors.append((idName, $0)) }
        titleResult.error.map { errors.append((titleName, $0)) }
        termsURLResult.error.map { errors.append((termsURLName, $0)) }
        sortPriorityResult.error.map { errors.append((sortPriorityName, $0)) }
        daysLeftResult.error.map { errors.append((daysLeftName, $0)) }
        productIdsResult.error.map { errors.append((productIdsName, $0)) }
        kindResult.error.map { errors.append((kindName, $0)) }
        subtitleResult.error.map { errors.append((subtitleName, $0)) }

        guard
            let id = idResult.value,
            let title = titleResult.value,
            let termsURL = termsURLResult.value,
            let sortPriority = sortPriorityResult.value,
            let daysLeft = daysLeftResult.value,
            let productIds = productIdsResult.value,
            let kind = kindResult.value,
            let subtitle = subtitleResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[idName] = id
        dictionary[titleName] = title
        dictionary[termsURLName] = termsURL
        dictionary[sortPriorityName] = sortPriority
        dictionary[daysLeftName] = daysLeft
        dictionary[productIdsName] = productIds
        dictionary[kindName] = kind
        dictionary[subtitleName] = subtitle
        return .success(dictionary)
    }
}
