// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct InteractiveSupportAnswerTransformer: Transformer {
    typealias Source = Any
    typealias Destination = InteractiveSupportAnswer

    let titleName = "title"
    let nextStepTypeName = "next_step_type"
    let nextQuestionIdName = "next_question_id"
    let keyName = "result_key"

    let titleTransformer = CastTransformer<Any, String>()
    let nextStepTypeTransformer = InteractiveSupportAnswerNextStepTypeTransformer()
    let nextQuestionIdTransformer = OptionalTransformer(transformer: NumberTransformer<Any, Int>())
    let keyTransformer = OptionalTransformer(transformer: CastTransformer<Any, String>())

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let titleResult = dictionary[titleName].map(titleTransformer.transform(source:)) ?? .failure(.requirement)
        let nextStepTypeResult = dictionary[nextStepTypeName].map(nextStepTypeTransformer.transform(source:)) ?? .failure(.requirement)
        let nextQuestionIdResult = nextQuestionIdTransformer.transform(source: dictionary[nextQuestionIdName])
        let keyResult = keyTransformer.transform(source: dictionary[keyName])

        var errors: [(String, TransformerError)] = []
        titleResult.error.map { errors.append((titleName, $0)) }
        nextStepTypeResult.error.map { errors.append((nextStepTypeName, $0)) }
        nextQuestionIdResult.error.map { errors.append((nextQuestionIdName, $0)) }
        keyResult.error.map { errors.append((keyName, $0)) }

        guard
            let title = titleResult.value,
            let nextStepType = nextStepTypeResult.value,
            let nextQuestionId = nextQuestionIdResult.value,
            let key = keyResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                title: title,
                nextStepType: nextStepType,
                nextQuestionId: nextQuestionId,
                key: key
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let titleResult = titleTransformer.transform(destination: value.title)
        let nextStepTypeResult = nextStepTypeTransformer.transform(destination: value.nextStepType)
        let nextQuestionIdResult = nextQuestionIdTransformer.transform(destination: value.nextQuestionId)
        let keyResult = keyTransformer.transform(destination: value.key)

        var errors: [(String, TransformerError)] = []
        titleResult.error.map { errors.append((titleName, $0)) }
        nextStepTypeResult.error.map { errors.append((nextStepTypeName, $0)) }
        nextQuestionIdResult.error.map { errors.append((nextQuestionIdName, $0)) }
        keyResult.error.map { errors.append((keyName, $0)) }

        guard
            let title = titleResult.value,
            let nextStepType = nextStepTypeResult.value,
            let nextQuestionId = nextQuestionIdResult.value,
            let key = keyResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[titleName] = title
        dictionary[nextStepTypeName] = nextStepType
        dictionary[nextQuestionIdName] = nextQuestionId
        dictionary[keyName] = key
        return .success(dictionary)
    }
}
