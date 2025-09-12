// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct DocumentsListTransformer: Transformer {
    typealias Source = Any
    typealias Destination = DocumentsList

    let idName = "id"
    let documentsName = "documents"
    let fullDescriptionName = "full_description"

    let idTransformer = IdTransformer<Any>()
    let documentsTransformer = ArrayTransformer(from: Any.self, transformer: CastTransformer<Any, String>(), skipFailures: true)
    let fullDescriptionTransformer = CastTransformer<Any, String>()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let idResult = dictionary[idName].map(idTransformer.transform(source:)) ?? .failure(.requirement)
        let documentsResult = dictionary[documentsName].map(documentsTransformer.transform(source:)) ?? .failure(.requirement)
        let fullDescriptionResult = dictionary[fullDescriptionName].map(fullDescriptionTransformer.transform(source:)) ?? .failure(.requirement)

        var errors: [(String, TransformerError)] = []
        idResult.error.map { errors.append((idName, $0)) }
        documentsResult.error.map { errors.append((documentsName, $0)) }
        fullDescriptionResult.error.map { errors.append((fullDescriptionName, $0)) }

        guard
            let id = idResult.value,
            let documents = documentsResult.value,
            let fullDescription = fullDescriptionResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                id: id,
                documents: documents,
                fullDescription: fullDescription
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let idResult = idTransformer.transform(destination: value.id)
        let documentsResult = documentsTransformer.transform(destination: value.documents)
        let fullDescriptionResult = fullDescriptionTransformer.transform(destination: value.fullDescription)

        var errors: [(String, TransformerError)] = []
        idResult.error.map { errors.append((idName, $0)) }
        documentsResult.error.map { errors.append((documentsName, $0)) }
        fullDescriptionResult.error.map { errors.append((fullDescriptionName, $0)) }

        guard
            let id = idResult.value,
            let documents = documentsResult.value,
            let fullDescription = fullDescriptionResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[idName] = id
        dictionary[documentsName] = documents
        dictionary[fullDescriptionName] = fullDescription
        return .success(dictionary)
    }
}
