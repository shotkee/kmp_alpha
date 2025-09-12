// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct OsagoProlongationErrorInfoTransformer: Transformer {
    typealias Source = Any
    typealias Destination = OsagoProlongationErrorInfo

    let titleName = "title"
    let messageName = "message"
    let errorsArrayName = "errors"

    let titleTransformer = CastTransformer<Any, String>()
    let messageTransformer = CastTransformer<Any, String>()
    let errorsArrayTransformer = ArrayTransformer(from: Any.self, transformer: CastTransformer<Any, String>(), skipFailures: true)

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let titleResult = dictionary[titleName].map(titleTransformer.transform(source:)) ?? .failure(.requirement)
        let messageResult = dictionary[messageName].map(messageTransformer.transform(source:)) ?? .failure(.requirement)
        let errorsArrayResult = dictionary[errorsArrayName].map(errorsArrayTransformer.transform(source:)) ?? .failure(.requirement)

        var errors: [(String, TransformerError)] = []
        titleResult.error.map { errors.append((titleName, $0)) }
        messageResult.error.map { errors.append((messageName, $0)) }
        errorsArrayResult.error.map { errors.append((errorsArrayName, $0)) }

        guard
            let title = titleResult.value,
            let message = messageResult.value,
            let errorsArray = errorsArrayResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                title: title,
                message: message,
                errorsArray: errorsArray
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let titleResult = titleTransformer.transform(destination: value.title)
        let messageResult = messageTransformer.transform(destination: value.message)
        let errorsArrayResult = errorsArrayTransformer.transform(destination: value.errorsArray)

        var errors: [(String, TransformerError)] = []
        titleResult.error.map { errors.append((titleName, $0)) }
        messageResult.error.map { errors.append((messageName, $0)) }
        errorsArrayResult.error.map { errors.append((errorsArrayName, $0)) }

        guard
            let title = titleResult.value,
            let message = messageResult.value,
            let errorsArray = errorsArrayResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[titleName] = title
        dictionary[messageName] = message
        dictionary[errorsArrayName] = errorsArray
        return .success(dictionary)
    }
}
