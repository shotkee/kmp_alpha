// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct NewPasswordRequirementTransformer: Transformer {
    typealias Source = Any
    typealias Destination = NewPasswordRequirement

    let titleName = "title"
    let regularExpressionStringName = "regexp"
    let visibilityConditionName = "visible"

    let titleTransformer = CastTransformer<Any, String>()
    let regularExpressionStringTransformer = OptionalTransformer(transformer: CastTransformer<Any, String>())
    let visibilityConditionTransformer = NewPasswordRequirementRegexpExecutionContextTransformer()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let titleResult = dictionary[titleName].map(titleTransformer.transform(source:)) ?? .failure(.requirement)
        let regularExpressionStringResult = regularExpressionStringTransformer.transform(source: dictionary[regularExpressionStringName])
        let visibilityConditionResult = dictionary[visibilityConditionName].map(visibilityConditionTransformer.transform(source:)) ?? .failure(.requirement)

        var errors: [(String, TransformerError)] = []
        titleResult.error.map { errors.append((titleName, $0)) }
        regularExpressionStringResult.error.map { errors.append((regularExpressionStringName, $0)) }
        visibilityConditionResult.error.map { errors.append((visibilityConditionName, $0)) }

        guard
            let title = titleResult.value,
            let regularExpressionString = regularExpressionStringResult.value,
            let visibilityCondition = visibilityConditionResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                title: title,
                regularExpressionString: regularExpressionString,
                visibilityCondition: visibilityCondition
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let titleResult = titleTransformer.transform(destination: value.title)
        let regularExpressionStringResult = regularExpressionStringTransformer.transform(destination: value.regularExpressionString)
        let visibilityConditionResult = visibilityConditionTransformer.transform(destination: value.visibilityCondition)

        var errors: [(String, TransformerError)] = []
        titleResult.error.map { errors.append((titleName, $0)) }
        regularExpressionStringResult.error.map { errors.append((regularExpressionStringName, $0)) }
        visibilityConditionResult.error.map { errors.append((visibilityConditionName, $0)) }

        guard
            let title = titleResult.value,
            let regularExpressionString = regularExpressionStringResult.value,
            let visibilityCondition = visibilityConditionResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[titleName] = title
        dictionary[regularExpressionStringName] = regularExpressionString
        dictionary[visibilityConditionName] = visibilityCondition
        return .success(dictionary)
    }
}
