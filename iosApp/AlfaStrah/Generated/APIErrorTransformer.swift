// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct APIErrorTransformer: Transformer {
    typealias Source = Any
    typealias Destination = APIError

    let httpCodeName = "code"
    let internalCodeName = "error_code"
    let titleName = "error_title"
    let messageName = "error_message"

    let httpCodeTransformer = NumberTransformer<Any, Int>()
    let internalCodeTransformer = NumberTransformer<Any, Int>()
    let titleTransformer = CastTransformer<Any, String>()
    let messageTransformer = CastTransformer<Any, String>()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let httpCodeResult = dictionary[httpCodeName].map(httpCodeTransformer.transform(source:)) ?? .failure(.requirement)
        let internalCodeResult = dictionary[internalCodeName].map(internalCodeTransformer.transform(source:)) ?? .failure(.requirement)
        let titleResult = dictionary[titleName].map(titleTransformer.transform(source:)) ?? .failure(.requirement)
        let messageResult = dictionary[messageName].map(messageTransformer.transform(source:)) ?? .failure(.requirement)

        var errors: [(String, TransformerError)] = []
        httpCodeResult.error.map { errors.append((httpCodeName, $0)) }
        internalCodeResult.error.map { errors.append((internalCodeName, $0)) }
        titleResult.error.map { errors.append((titleName, $0)) }
        messageResult.error.map { errors.append((messageName, $0)) }

        guard
            let httpCode = httpCodeResult.value,
            let internalCode = internalCodeResult.value,
            let title = titleResult.value,
            let message = messageResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                httpCode: httpCode,
                internalCode: internalCode,
                title: title,
                message: message
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let httpCodeResult = httpCodeTransformer.transform(destination: value.httpCode)
        let internalCodeResult = internalCodeTransformer.transform(destination: value.internalCode)
        let titleResult = titleTransformer.transform(destination: value.title)
        let messageResult = messageTransformer.transform(destination: value.message)

        var errors: [(String, TransformerError)] = []
        httpCodeResult.error.map { errors.append((httpCodeName, $0)) }
        internalCodeResult.error.map { errors.append((internalCodeName, $0)) }
        titleResult.error.map { errors.append((titleName, $0)) }
        messageResult.error.map { errors.append((messageName, $0)) }

        guard
            let httpCode = httpCodeResult.value,
            let internalCode = internalCodeResult.value,
            let title = titleResult.value,
            let message = messageResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[httpCodeName] = httpCode
        dictionary[internalCodeName] = internalCode
        dictionary[titleName] = title
        dictionary[messageName] = message
        return .success(dictionary)
    }
}
