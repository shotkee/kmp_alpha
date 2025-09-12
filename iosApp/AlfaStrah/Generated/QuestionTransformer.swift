// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct QuestionTransformer: Transformer {
    typealias Source = Any
    typealias Destination = Question

    let idName = "id"
    let isFrequentName = "is_frequent"
    let questionTextName = "question_text"
    let answerHtmlName = "answer_full"
    let lastModifiedName = "last_modified"

    let idTransformer = IdTransformer<Any>()
    let isFrequentTransformer = NumberTransformer<Any, Bool>()
    let questionTextTransformer = CastTransformer<Any, String>()
    let answerHtmlTransformer = CastTransformer<Any, String>()
    let lastModifiedTransformer = TimestampTransformer<Any>(scale: 1)

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let idResult = dictionary[idName].map(idTransformer.transform(source:)) ?? .failure(.requirement)
        let isFrequentResult = dictionary[isFrequentName].map(isFrequentTransformer.transform(source:)) ?? .failure(.requirement)
        let questionTextResult = dictionary[questionTextName].map(questionTextTransformer.transform(source:)) ?? .failure(.requirement)
        let answerHtmlResult = dictionary[answerHtmlName].map(answerHtmlTransformer.transform(source:)) ?? .failure(.requirement)
        let lastModifiedResult = dictionary[lastModifiedName].map(lastModifiedTransformer.transform(source:)) ?? .failure(.requirement)

        var errors: [(String, TransformerError)] = []
        idResult.error.map { errors.append((idName, $0)) }
        isFrequentResult.error.map { errors.append((isFrequentName, $0)) }
        questionTextResult.error.map { errors.append((questionTextName, $0)) }
        answerHtmlResult.error.map { errors.append((answerHtmlName, $0)) }
        lastModifiedResult.error.map { errors.append((lastModifiedName, $0)) }

        guard
            let id = idResult.value,
            let isFrequent = isFrequentResult.value,
            let questionText = questionTextResult.value,
            let answerHtml = answerHtmlResult.value,
            let lastModified = lastModifiedResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                id: id,
                isFrequent: isFrequent,
                questionText: questionText,
                answerHtml: answerHtml,
                lastModified: lastModified
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let idResult = idTransformer.transform(destination: value.id)
        let isFrequentResult = isFrequentTransformer.transform(destination: value.isFrequent)
        let questionTextResult = questionTextTransformer.transform(destination: value.questionText)
        let answerHtmlResult = answerHtmlTransformer.transform(destination: value.answerHtml)
        let lastModifiedResult = lastModifiedTransformer.transform(destination: value.lastModified)

        var errors: [(String, TransformerError)] = []
        idResult.error.map { errors.append((idName, $0)) }
        isFrequentResult.error.map { errors.append((isFrequentName, $0)) }
        questionTextResult.error.map { errors.append((questionTextName, $0)) }
        answerHtmlResult.error.map { errors.append((answerHtmlName, $0)) }
        lastModifiedResult.error.map { errors.append((lastModifiedName, $0)) }

        guard
            let id = idResult.value,
            let isFrequent = isFrequentResult.value,
            let questionText = questionTextResult.value,
            let answerHtml = answerHtmlResult.value,
            let lastModified = lastModifiedResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[idName] = id
        dictionary[isFrequentName] = isFrequent
        dictionary[questionTextName] = questionText
        dictionary[answerHtmlName] = answerHtml
        dictionary[lastModifiedName] = lastModified
        return .success(dictionary)
    }
}
