// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct DmsCostRecoveryConditionTransformer: Transformer {
    typealias Source = Any
    typealias Destination = DmsCostRecoveryCondition

    let stepNumberName = "number"
    let titleName = "title"

    let stepNumberTransformer = NumberTransformer<Any, Int>()
    let titleTransformer = CastTransformer<Any, String>()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let stepNumberResult = dictionary[stepNumberName].map(stepNumberTransformer.transform(source:)) ?? .failure(.requirement)
        let titleResult = dictionary[titleName].map(titleTransformer.transform(source:)) ?? .failure(.requirement)

        var errors: [(String, TransformerError)] = []
        stepNumberResult.error.map { errors.append((stepNumberName, $0)) }
        titleResult.error.map { errors.append((titleName, $0)) }

        guard
            let stepNumber = stepNumberResult.value,
            let title = titleResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                stepNumber: stepNumber,
                title: title
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let stepNumberResult = stepNumberTransformer.transform(destination: value.stepNumber)
        let titleResult = titleTransformer.transform(destination: value.title)

        var errors: [(String, TransformerError)] = []
        stepNumberResult.error.map { errors.append((stepNumberName, $0)) }
        titleResult.error.map { errors.append((titleName, $0)) }

        guard
            let stepNumber = stepNumberResult.value,
            let title = titleResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[stepNumberName] = stepNumber
        dictionary[titleName] = title
        return .success(dictionary)
    }
}
