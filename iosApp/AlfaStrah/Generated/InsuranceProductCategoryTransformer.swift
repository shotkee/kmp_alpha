// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct InsuranceProductCategoryTransformer: Transformer {
    typealias Source = Any
    typealias Destination = InsuranceProductCategory

    let idName = "category_id"
    let titleName = "title"
    let productListName = "product_list"
    let showInFiltersName = "show_in_filters"

    let idTransformer = NumberTransformer<Any, Int64>()
    let titleTransformer = CastTransformer<Any, String>()
    let productListTransformer = ArrayTransformer(from: Any.self, transformer: InsuranceProductTransformer(), skipFailures: true)
    let showInFiltersTransformer = NumberTransformer<Any, Bool>()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let idResult = dictionary[idName].map(idTransformer.transform(source:)) ?? .failure(.requirement)
        let titleResult = dictionary[titleName].map(titleTransformer.transform(source:)) ?? .failure(.requirement)
        let productListResult = dictionary[productListName].map(productListTransformer.transform(source:)) ?? .failure(.requirement)
        let showInFiltersResult = dictionary[showInFiltersName].map(showInFiltersTransformer.transform(source:)) ?? .failure(.requirement)

        var errors: [(String, TransformerError)] = []
        idResult.error.map { errors.append((idName, $0)) }
        titleResult.error.map { errors.append((titleName, $0)) }
        productListResult.error.map { errors.append((productListName, $0)) }
        showInFiltersResult.error.map { errors.append((showInFiltersName, $0)) }

        guard
            let id = idResult.value,
            let title = titleResult.value,
            let productList = productListResult.value,
            let showInFilters = showInFiltersResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                id: id,
                title: title,
                productList: productList,
                showInFilters: showInFilters
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let idResult = idTransformer.transform(destination: value.id)
        let titleResult = titleTransformer.transform(destination: value.title)
        let productListResult = productListTransformer.transform(destination: value.productList)
        let showInFiltersResult = showInFiltersTransformer.transform(destination: value.showInFilters)

        var errors: [(String, TransformerError)] = []
        idResult.error.map { errors.append((idName, $0)) }
        titleResult.error.map { errors.append((titleName, $0)) }
        productListResult.error.map { errors.append((productListName, $0)) }
        showInFiltersResult.error.map { errors.append((showInFiltersName, $0)) }

        guard
            let id = idResult.value,
            let title = titleResult.value,
            let productList = productListResult.value,
            let showInFilters = showInFiltersResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[idName] = id
        dictionary[titleName] = title
        dictionary[productListName] = productList
        dictionary[showInFiltersName] = showInFilters
        return .success(dictionary)
    }
}
