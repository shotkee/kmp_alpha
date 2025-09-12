// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct AskQuestionRequestTransformer: Transformer {
    typealias Source = Any
    typealias Destination = AskQuestionRequest

    let textName = "question_text"
    let phoneName = "phone"
    let destinationName = "destination"
    let questionIdName = "question_id"

    let textTransformer = CastTransformer<Any, String>()
    let phoneTransformer = CastTransformer<Any, String>()
    let destinationTransformer = OptionalTransformer(transformer: CastTransformer<Any, String>())
    let questionIdTransformer = OptionalTransformer(transformer: NumberTransformer<Any, Int>())

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let textResult = dictionary[textName].map(textTransformer.transform(source:)) ?? .failure(.requirement)
        let phoneResult = dictionary[phoneName].map(phoneTransformer.transform(source:)) ?? .failure(.requirement)
        let destinationResult = destinationTransformer.transform(source: dictionary[destinationName])
        let questionIdResult = questionIdTransformer.transform(source: dictionary[questionIdName])

        var errors: [(String, TransformerError)] = []
        textResult.error.map { errors.append((textName, $0)) }
        phoneResult.error.map { errors.append((phoneName, $0)) }
        destinationResult.error.map { errors.append((destinationName, $0)) }
        questionIdResult.error.map { errors.append((questionIdName, $0)) }

        guard
            let text = textResult.value,
            let phone = phoneResult.value,
            let destination = destinationResult.value,
            let questionId = questionIdResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                text: text,
                phone: phone,
                destination: destination,
                questionId: questionId
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let textResult = textTransformer.transform(destination: value.text)
        let phoneResult = phoneTransformer.transform(destination: value.phone)
        let destinationResult = destinationTransformer.transform(destination: value.destination)
        let questionIdResult = questionIdTransformer.transform(destination: value.questionId)

        var errors: [(String, TransformerError)] = []
        textResult.error.map { errors.append((textName, $0)) }
        phoneResult.error.map { errors.append((phoneName, $0)) }
        destinationResult.error.map { errors.append((destinationName, $0)) }
        questionIdResult.error.map { errors.append((questionIdName, $0)) }

        guard
            let text = textResult.value,
            let phone = phoneResult.value,
            let destination = destinationResult.value,
            let questionId = questionIdResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[textName] = text
        dictionary[phoneName] = phone
        dictionary[destinationName] = destination
        dictionary[questionIdName] = questionId
        return .success(dictionary)
    }
}
