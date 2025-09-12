// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct DraftsCalculationsCategoriesWithInfoTransformer: Transformer {
    typealias Source = Any
    typealias Destination = DraftsCalculationsCategoriesWithInfo

    let draftCategoriesName = "draft_category_list"
    let informationName = "information"

    let draftCategoriesTransformer = ArrayTransformer(from: Any.self, transformer: DraftsCalculationsCategoryTransformer(), skipFailures: true)
    let informationTransformer = CastTransformer<Any, String>()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let draftCategoriesResult = dictionary[draftCategoriesName].map(draftCategoriesTransformer.transform(source:)) ?? .failure(.requirement)
        let informationResult = dictionary[informationName].map(informationTransformer.transform(source:)) ?? .failure(.requirement)

        var errors: [(String, TransformerError)] = []
        draftCategoriesResult.error.map { errors.append((draftCategoriesName, $0)) }
        informationResult.error.map { errors.append((informationName, $0)) }

        guard
            let draftCategories = draftCategoriesResult.value,
            let information = informationResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                draftCategories: draftCategories,
                information: information
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let draftCategoriesResult = draftCategoriesTransformer.transform(destination: value.draftCategories)
        let informationResult = informationTransformer.transform(destination: value.information)

        var errors: [(String, TransformerError)] = []
        draftCategoriesResult.error.map { errors.append((draftCategoriesName, $0)) }
        informationResult.error.map { errors.append((informationName, $0)) }

        guard
            let draftCategories = draftCategoriesResult.value,
            let information = informationResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[draftCategoriesName] = draftCategories
        dictionary[informationName] = information
        return .success(dictionary)
    }
}
