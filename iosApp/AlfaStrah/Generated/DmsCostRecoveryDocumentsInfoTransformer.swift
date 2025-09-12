// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct DmsCostRecoveryDocumentsInfoTransformer: Transformer {
    typealias Source = Any
    typealias Destination = DmsCostRecoveryDocumentsInfo

    let documentsByTypeName = "file_type_list"
    let maximumUploadSizeName = "files_limit"
    let descriptionName = "description"

    let documentsByTypeTransformer = ArrayTransformer(from: Any.self, transformer: DmsCostRecoveryDocumentsByTypeTransformer(), skipFailures: true)
    let maximumUploadSizeTransformer = NumberTransformer<Any, Int>()
    let descriptionTransformer = OptionalTransformer(transformer: CastTransformer<Any, String>())

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let documentsByTypeResult = dictionary[documentsByTypeName].map(documentsByTypeTransformer.transform(source:)) ?? .failure(.requirement)
        let maximumUploadSizeResult = dictionary[maximumUploadSizeName].map(maximumUploadSizeTransformer.transform(source:)) ?? .failure(.requirement)
        let descriptionResult = descriptionTransformer.transform(source: dictionary[descriptionName])

        var errors: [(String, TransformerError)] = []
        documentsByTypeResult.error.map { errors.append((documentsByTypeName, $0)) }
        maximumUploadSizeResult.error.map { errors.append((maximumUploadSizeName, $0)) }
        descriptionResult.error.map { errors.append((descriptionName, $0)) }

        guard
            let documentsByType = documentsByTypeResult.value,
            let maximumUploadSize = maximumUploadSizeResult.value,
            let description = descriptionResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                documentsByType: documentsByType,
                maximumUploadSize: maximumUploadSize,
                description: description
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let documentsByTypeResult = documentsByTypeTransformer.transform(destination: value.documentsByType)
        let maximumUploadSizeResult = maximumUploadSizeTransformer.transform(destination: value.maximumUploadSize)
        let descriptionResult = descriptionTransformer.transform(destination: value.description)

        var errors: [(String, TransformerError)] = []
        documentsByTypeResult.error.map { errors.append((documentsByTypeName, $0)) }
        maximumUploadSizeResult.error.map { errors.append((maximumUploadSizeName, $0)) }
        descriptionResult.error.map { errors.append((descriptionName, $0)) }

        guard
            let documentsByType = documentsByTypeResult.value,
            let maximumUploadSize = maximumUploadSizeResult.value,
            let description = descriptionResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[documentsByTypeName] = documentsByType
        dictionary[maximumUploadSizeName] = maximumUploadSize
        dictionary[descriptionName] = description
        return .success(dictionary)
    }
}
