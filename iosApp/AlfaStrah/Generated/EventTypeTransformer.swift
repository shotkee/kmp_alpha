// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct EventTypeTransformer: Transformer {
    typealias Source = Any
    typealias Destination = EventType

    let idName = "id"
    let titleName = "title"
    let fullDescriptionName = "full_description"
    let infoName = "info"
    let documentsName = "documents_list"
    let optionalDocumentsName = "documents_list_optional"

    let idTransformer = IdTransformer<Any>()
    let titleTransformer = CastTransformer<Any, String>()
    let fullDescriptionTransformer = CastTransformer<Any, String>()
    let infoTransformer = OptionalTransformer(transformer: ArrayTransformer(from: Any.self, transformer: EventTypeInfoTransformer(), skipFailures: true))
    let documentsTransformer = OptionalTransformer(transformer: DocumentsListTransformer())
    let optionalDocumentsTransformer = OptionalTransformer(transformer: DocumentsListTransformer())

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let idResult = dictionary[idName].map(idTransformer.transform(source:)) ?? .failure(.requirement)
        let titleResult = dictionary[titleName].map(titleTransformer.transform(source:)) ?? .failure(.requirement)
        let fullDescriptionResult = dictionary[fullDescriptionName].map(fullDescriptionTransformer.transform(source:)) ?? .failure(.requirement)
        let infoResult = infoTransformer.transform(source: dictionary[infoName])
        let documentsResult = documentsTransformer.transform(source: dictionary[documentsName])
        let optionalDocumentsResult = optionalDocumentsTransformer.transform(source: dictionary[optionalDocumentsName])

        var errors: [(String, TransformerError)] = []
        idResult.error.map { errors.append((idName, $0)) }
        titleResult.error.map { errors.append((titleName, $0)) }
        fullDescriptionResult.error.map { errors.append((fullDescriptionName, $0)) }
        infoResult.error.map { errors.append((infoName, $0)) }
        documentsResult.error.map { errors.append((documentsName, $0)) }
        optionalDocumentsResult.error.map { errors.append((optionalDocumentsName, $0)) }

        guard
            let id = idResult.value,
            let title = titleResult.value,
            let fullDescription = fullDescriptionResult.value,
            let info = infoResult.value,
            let documents = documentsResult.value,
            let optionalDocuments = optionalDocumentsResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                id: id,
                title: title,
                fullDescription: fullDescription,
                info: info,
                documents: documents,
                optionalDocuments: optionalDocuments
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let idResult = idTransformer.transform(destination: value.id)
        let titleResult = titleTransformer.transform(destination: value.title)
        let fullDescriptionResult = fullDescriptionTransformer.transform(destination: value.fullDescription)
        let infoResult = infoTransformer.transform(destination: value.info)
        let documentsResult = documentsTransformer.transform(destination: value.documents)
        let optionalDocumentsResult = optionalDocumentsTransformer.transform(destination: value.optionalDocuments)

        var errors: [(String, TransformerError)] = []
        idResult.error.map { errors.append((idName, $0)) }
        titleResult.error.map { errors.append((titleName, $0)) }
        fullDescriptionResult.error.map { errors.append((fullDescriptionName, $0)) }
        infoResult.error.map { errors.append((infoName, $0)) }
        documentsResult.error.map { errors.append((documentsName, $0)) }
        optionalDocumentsResult.error.map { errors.append((optionalDocumentsName, $0)) }

        guard
            let id = idResult.value,
            let title = titleResult.value,
            let fullDescription = fullDescriptionResult.value,
            let info = infoResult.value,
            let documents = documentsResult.value,
            let optionalDocuments = optionalDocumentsResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[idName] = id
        dictionary[titleName] = title
        dictionary[fullDescriptionName] = fullDescription
        dictionary[infoName] = info
        dictionary[documentsName] = documents
        dictionary[optionalDocumentsName] = optionalDocuments
        return .success(dictionary)
    }
}
