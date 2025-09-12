// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct RiskCategoryTransformer: Transformer {
    typealias Source = Any
    typealias Destination = RiskCategory

    let idName = "id"
    let titleName = "title"
    let kindName = "type"
    let dependencyName = "dependence"
    let riskDataName = "risk_data_list"

    let idTransformer = IdTransformer<Any>()
    let titleTransformer = OptionalTransformer(transformer: CastTransformer<Any, String>())
    let kindTransformer = RiskCategoryRiskCategoryKindTransformer()
    let dependencyTransformer = OptionalTransformer(transformer: RiskDataDependencyTransformer())
    let riskDataTransformer = ArrayTransformer(from: Any.self, transformer: RiskDataTransformer(), skipFailures: true)

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let idResult = dictionary[idName].map(idTransformer.transform(source:)) ?? .failure(.requirement)
        let titleResult = titleTransformer.transform(source: dictionary[titleName])
        let kindResult = dictionary[kindName].map(kindTransformer.transform(source:)) ?? .failure(.requirement)
        let dependencyResult = dependencyTransformer.transform(source: dictionary[dependencyName])
        let riskDataResult = dictionary[riskDataName].map(riskDataTransformer.transform(source:)) ?? .failure(.requirement)

        var errors: [(String, TransformerError)] = []
        idResult.error.map { errors.append((idName, $0)) }
        titleResult.error.map { errors.append((titleName, $0)) }
        kindResult.error.map { errors.append((kindName, $0)) }
        dependencyResult.error.map { errors.append((dependencyName, $0)) }
        riskDataResult.error.map { errors.append((riskDataName, $0)) }

        guard
            let id = idResult.value,
            let title = titleResult.value,
            let kind = kindResult.value,
            let dependency = dependencyResult.value,
            let riskData = riskDataResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                id: id,
                title: title,
                kind: kind,
                dependency: dependency,
                riskData: riskData
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let idResult = idTransformer.transform(destination: value.id)
        let titleResult = titleTransformer.transform(destination: value.title)
        let kindResult = kindTransformer.transform(destination: value.kind)
        let dependencyResult = dependencyTransformer.transform(destination: value.dependency)
        let riskDataResult = riskDataTransformer.transform(destination: value.riskData)

        var errors: [(String, TransformerError)] = []
        idResult.error.map { errors.append((idName, $0)) }
        titleResult.error.map { errors.append((titleName, $0)) }
        kindResult.error.map { errors.append((kindName, $0)) }
        dependencyResult.error.map { errors.append((dependencyName, $0)) }
        riskDataResult.error.map { errors.append((riskDataName, $0)) }

        guard
            let id = idResult.value,
            let title = titleResult.value,
            let kind = kindResult.value,
            let dependency = dependencyResult.value,
            let riskData = riskDataResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[idName] = id
        dictionary[titleName] = title
        dictionary[kindName] = kind
        dictionary[dependencyName] = dependency
        dictionary[riskDataName] = riskData
        return .success(dictionary)
    }
}
