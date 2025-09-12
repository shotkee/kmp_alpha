// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct FileUploadResponseTransformer: Transformer {
    typealias Source = Any
    typealias Destination = FileUploadResponse

    let successName = "success"
    let messageName = "message"
    let documentIdName = "document_id"

    let successTransformer = NumberTransformer<Any, Bool>()
    let messageTransformer = CastTransformer<Any, String>()
    let documentIdTransformer = CastTransformer<Any, String>()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let successResult = dictionary[successName].map(successTransformer.transform(source:)) ?? .failure(.requirement)
        let messageResult = dictionary[messageName].map(messageTransformer.transform(source:)) ?? .failure(.requirement)
        let documentIdResult = dictionary[documentIdName].map(documentIdTransformer.transform(source:)) ?? .failure(.requirement)

        var errors: [(String, TransformerError)] = []
        successResult.error.map { errors.append((successName, $0)) }
        messageResult.error.map { errors.append((messageName, $0)) }
        documentIdResult.error.map { errors.append((documentIdName, $0)) }

        guard
            let success = successResult.value,
            let message = messageResult.value,
            let documentId = documentIdResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                success: success,
                message: message,
                documentId: documentId
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let successResult = successTransformer.transform(destination: value.success)
        let messageResult = messageTransformer.transform(destination: value.message)
        let documentIdResult = documentIdTransformer.transform(destination: value.documentId)

        var errors: [(String, TransformerError)] = []
        successResult.error.map { errors.append((successName, $0)) }
        messageResult.error.map { errors.append((messageName, $0)) }
        documentIdResult.error.map { errors.append((documentIdName, $0)) }

        guard
            let success = successResult.value,
            let message = messageResult.value,
            let documentId = documentIdResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[successName] = success
        dictionary[messageName] = message
        dictionary[documentIdName] = documentId
        return .success(dictionary)
    }
}
