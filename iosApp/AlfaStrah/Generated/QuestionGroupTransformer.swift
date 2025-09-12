// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct QuestionGroupTransformer: Transformer {
    typealias Source = Any
    typealias Destination = QuestionGroup

    let titleName = "title"
    let questionListName = "question_list"

    let titleTransformer = CastTransformer<Any, String>()
    let questionListTransformer = ArrayTransformer(from: Any.self, transformer: QuestionTransformer(), skipFailures: true)

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let titleResult = dictionary[titleName].map(titleTransformer.transform(source:)) ?? .failure(.requirement)
        let questionListResult = dictionary[questionListName].map(questionListTransformer.transform(source:)) ?? .failure(.requirement)

        var errors: [(String, TransformerError)] = []
        titleResult.error.map { errors.append((titleName, $0)) }
        questionListResult.error.map { errors.append((questionListName, $0)) }

        guard
            let title = titleResult.value,
            let questionList = questionListResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                title: title,
                questionList: questionList
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let titleResult = titleTransformer.transform(destination: value.title)
        let questionListResult = questionListTransformer.transform(destination: value.questionList)

        var errors: [(String, TransformerError)] = []
        titleResult.error.map { errors.append((titleName, $0)) }
        questionListResult.error.map { errors.append((questionListName, $0)) }

        guard
            let title = titleResult.value,
            let questionList = questionListResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[titleName] = title
        dictionary[questionListName] = questionList
        return .success(dictionary)
    }
}
