// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct InteractiveSupportQuestionsResponseTransformer: Transformer {
    typealias Source = Any
    typealias Destination = InteractiveSupportQuestionsResponse

    let questionsName = "questions"
    let firstQuestionIdName = "first_question_id"

    let questionsTransformer = ArrayTransformer(from: Any.self, transformer: InteractiveSupportQuestionTransformer(), skipFailures: true)
    let firstQuestionIdTransformer = NumberTransformer<Any, Int>()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let questionsResult = dictionary[questionsName].map(questionsTransformer.transform(source:)) ?? .failure(.requirement)
        let firstQuestionIdResult = dictionary[firstQuestionIdName].map(firstQuestionIdTransformer.transform(source:)) ?? .failure(.requirement)

        var errors: [(String, TransformerError)] = []
        questionsResult.error.map { errors.append((questionsName, $0)) }
        firstQuestionIdResult.error.map { errors.append((firstQuestionIdName, $0)) }

        guard
            let questions = questionsResult.value,
            let firstQuestionId = firstQuestionIdResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                questions: questions,
                firstQuestionId: firstQuestionId
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let questionsResult = questionsTransformer.transform(destination: value.questions)
        let firstQuestionIdResult = firstQuestionIdTransformer.transform(destination: value.firstQuestionId)

        var errors: [(String, TransformerError)] = []
        questionsResult.error.map { errors.append((questionsName, $0)) }
        firstQuestionIdResult.error.map { errors.append((firstQuestionIdName, $0)) }

        guard
            let questions = questionsResult.value,
            let firstQuestionId = firstQuestionIdResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[questionsName] = questions
        dictionary[firstQuestionIdName] = firstQuestionId
        return .success(dictionary)
    }
}
