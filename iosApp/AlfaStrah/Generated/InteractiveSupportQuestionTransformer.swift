// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct InteractiveSupportQuestionTransformer: Transformer {
    typealias Source = Any
    typealias Destination = InteractiveSupportQuestion

    let idName = "question_id"
    let titleName = "title"
    let answersName = "answers"

    let idTransformer = NumberTransformer<Any, Int>()
    let titleTransformer = CastTransformer<Any, String>()
    let answersTransformer = ArrayTransformer(from: Any.self, transformer: InteractiveSupportAnswerTransformer(), skipFailures: true)

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let idResult = dictionary[idName].map(idTransformer.transform(source:)) ?? .failure(.requirement)
        let titleResult = dictionary[titleName].map(titleTransformer.transform(source:)) ?? .failure(.requirement)
        let answersResult = dictionary[answersName].map(answersTransformer.transform(source:)) ?? .failure(.requirement)

        var errors: [(String, TransformerError)] = []
        idResult.error.map { errors.append((idName, $0)) }
        titleResult.error.map { errors.append((titleName, $0)) }
        answersResult.error.map { errors.append((answersName, $0)) }

        guard
            let id = idResult.value,
            let title = titleResult.value,
            let answers = answersResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                id: id,
                title: title,
                answers: answers
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let idResult = idTransformer.transform(destination: value.id)
        let titleResult = titleTransformer.transform(destination: value.title)
        let answersResult = answersTransformer.transform(destination: value.answers)

        var errors: [(String, TransformerError)] = []
        idResult.error.map { errors.append((idName, $0)) }
        titleResult.error.map { errors.append((titleName, $0)) }
        answersResult.error.map { errors.append((answersName, $0)) }

        guard
            let id = idResult.value,
            let title = titleResult.value,
            let answers = answersResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[idName] = id
        dictionary[titleName] = title
        dictionary[answersName] = answers
        return .success(dictionary)
    }
}
