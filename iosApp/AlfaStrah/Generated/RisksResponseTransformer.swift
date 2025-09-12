// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct RisksResponseTransformer: Transformer {
    typealias Source = Any
    typealias Destination = RisksResponse

    let risksName = "risk_list"
    let riskCategoriesName = "declarer_risk_category_list"

    let risksTransformer = ArrayTransformer(from: Any.self, transformer: RiskTransformer(), skipFailures: true)
    let riskCategoriesTransformer = ArrayTransformer(from: Any.self, transformer: RiskCategoryTransformer(), skipFailures: true)

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let risksResult = dictionary[risksName].map(risksTransformer.transform(source:)) ?? .failure(.requirement)
        let riskCategoriesResult = dictionary[riskCategoriesName].map(riskCategoriesTransformer.transform(source:)) ?? .failure(.requirement)

        var errors: [(String, TransformerError)] = []
        risksResult.error.map { errors.append((risksName, $0)) }
        riskCategoriesResult.error.map { errors.append((riskCategoriesName, $0)) }

        guard
            let risks = risksResult.value,
            let riskCategories = riskCategoriesResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                risks: risks,
                riskCategories: riskCategories
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let risksResult = risksTransformer.transform(destination: value.risks)
        let riskCategoriesResult = riskCategoriesTransformer.transform(destination: value.riskCategories)

        var errors: [(String, TransformerError)] = []
        risksResult.error.map { errors.append((risksName, $0)) }
        riskCategoriesResult.error.map { errors.append((riskCategoriesName, $0)) }

        guard
            let risks = risksResult.value,
            let riskCategories = riskCategoriesResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[risksName] = risks
        dictionary[riskCategoriesName] = riskCategories
        return .success(dictionary)
    }
}
