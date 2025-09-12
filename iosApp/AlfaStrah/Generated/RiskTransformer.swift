// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct RiskTransformer: Transformer {
    typealias Source = Any
    typealias Destination = Risk

    let idName = "id"
    let titleName = "title"
    let exclusiveIdsName = "nomatch_id_list"
    let riskCategoriesName = "risk_category_list"

    let idTransformer = IdTransformer<Any>()
    let titleTransformer = CastTransformer<Any, String>()
    let exclusiveIdsTransformer = ArrayTransformer(from: Any.self, transformer: CastTransformer<Any, String>(), skipFailures: true)
    let riskCategoriesTransformer = ArrayTransformer(from: Any.self, transformer: RiskCategoryTransformer(), skipFailures: true)

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let idResult = dictionary[idName].map(idTransformer.transform(source:)) ?? .failure(.requirement)
        let titleResult = dictionary[titleName].map(titleTransformer.transform(source:)) ?? .failure(.requirement)
        let exclusiveIdsResult = dictionary[exclusiveIdsName].map(exclusiveIdsTransformer.transform(source:)) ?? .failure(.requirement)
        let riskCategoriesResult = dictionary[riskCategoriesName].map(riskCategoriesTransformer.transform(source:)) ?? .failure(.requirement)

        var errors: [(String, TransformerError)] = []
        idResult.error.map { errors.append((idName, $0)) }
        titleResult.error.map { errors.append((titleName, $0)) }
        exclusiveIdsResult.error.map { errors.append((exclusiveIdsName, $0)) }
        riskCategoriesResult.error.map { errors.append((riskCategoriesName, $0)) }

        guard
            let id = idResult.value,
            let title = titleResult.value,
            let exclusiveIds = exclusiveIdsResult.value,
            let riskCategories = riskCategoriesResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                id: id,
                title: title,
                exclusiveIds: exclusiveIds,
                riskCategories: riskCategories
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let idResult = idTransformer.transform(destination: value.id)
        let titleResult = titleTransformer.transform(destination: value.title)
        let exclusiveIdsResult = exclusiveIdsTransformer.transform(destination: value.exclusiveIds)
        let riskCategoriesResult = riskCategoriesTransformer.transform(destination: value.riskCategories)

        var errors: [(String, TransformerError)] = []
        idResult.error.map { errors.append((idName, $0)) }
        titleResult.error.map { errors.append((titleName, $0)) }
        exclusiveIdsResult.error.map { errors.append((exclusiveIdsName, $0)) }
        riskCategoriesResult.error.map { errors.append((riskCategoriesName, $0)) }

        guard
            let id = idResult.value,
            let title = titleResult.value,
            let exclusiveIds = exclusiveIdsResult.value,
            let riskCategories = riskCategoriesResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[idName] = id
        dictionary[titleName] = title
        dictionary[exclusiveIdsName] = exclusiveIds
        dictionary[riskCategoriesName] = riskCategories
        return .success(dictionary)
    }
}
