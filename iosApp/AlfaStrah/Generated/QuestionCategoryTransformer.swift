// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct QuestionCategoryTransformer: Transformer {
    typealias Source = Any
    typealias Destination = QuestionCategory

    let idName = "id"
    let titleName = "title"
    let questionGroupListName = "question_group_list"

    let idTransformer = IdTransformer<Any>()
    let titleTransformer = CastTransformer<Any, String>()
    let questionGroupListTransformer = ArrayTransformer(from: Any.self, transformer: QuestionGroupTransformer(), skipFailures: true)

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let idResult = dictionary[idName].map(idTransformer.transform(source:)) ?? .failure(.requirement)
        let titleResult = dictionary[titleName].map(titleTransformer.transform(source:)) ?? .failure(.requirement)
        let questionGroupListResult = dictionary[questionGroupListName].map(questionGroupListTransformer.transform(source:)) ?? .failure(.requirement)

        var errors: [(String, TransformerError)] = []
        idResult.error.map { errors.append((idName, $0)) }
        titleResult.error.map { errors.append((titleName, $0)) }
        questionGroupListResult.error.map { errors.append((questionGroupListName, $0)) }

        guard
            let id = idResult.value,
            let title = titleResult.value,
            let questionGroupList = questionGroupListResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                id: id,
                title: title,
                questionGroupList: questionGroupList
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let idResult = idTransformer.transform(destination: value.id)
        let titleResult = titleTransformer.transform(destination: value.title)
        let questionGroupListResult = questionGroupListTransformer.transform(destination: value.questionGroupList)

        var errors: [(String, TransformerError)] = []
        idResult.error.map { errors.append((idName, $0)) }
        titleResult.error.map { errors.append((titleName, $0)) }
        questionGroupListResult.error.map { errors.append((questionGroupListName, $0)) }

        guard
            let id = idResult.value,
            let title = titleResult.value,
            let questionGroupList = questionGroupListResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[idName] = id
        dictionary[titleName] = title
        dictionary[questionGroupListName] = questionGroupList
        return .success(dictionary)
    }
}
