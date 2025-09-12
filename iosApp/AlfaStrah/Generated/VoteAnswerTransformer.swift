// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct VoteAnswerTransformer: Transformer {
    typealias Source = Any
    typealias Destination = VoteAnswer

    let questionIdName = "question_id"
    let answerName = "is_usefull"

    let questionIdTransformer = NumberTransformer<Any, Int>()
    let answerTransformer = VoteAnswerAnswerTransformer()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let questionIdResult = dictionary[questionIdName].map(questionIdTransformer.transform(source:)) ?? .failure(.requirement)
        let answerResult = dictionary[answerName].map(answerTransformer.transform(source:)) ?? .failure(.requirement)

        var errors: [(String, TransformerError)] = []
        questionIdResult.error.map { errors.append((questionIdName, $0)) }
        answerResult.error.map { errors.append((answerName, $0)) }

        guard
            let questionId = questionIdResult.value,
            let answer = answerResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                questionId: questionId,
                answer: answer
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let questionIdResult = questionIdTransformer.transform(destination: value.questionId)
        let answerResult = answerTransformer.transform(destination: value.answer)

        var errors: [(String, TransformerError)] = []
        questionIdResult.error.map { errors.append((questionIdName, $0)) }
        answerResult.error.map { errors.append((answerName, $0)) }

        guard
            let questionId = questionIdResult.value,
            let answer = answerResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[questionIdName] = questionId
        dictionary[answerName] = answer
        return .success(dictionary)
    }
}
