// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct DmsCostRecoveryDocumentsByTypeTransformer: Transformer {
    typealias Source = Any
    typealias Destination = DmsCostRecoveryDocumentsByType

    let titleName = "title"
    let documentsListsName = "file_group_list"

    let titleTransformer = CastTransformer<Any, String>()
    let documentsListsTransformer = ArrayTransformer(from: Any.self, transformer: DmsCostRecoveryDocumentsListTransformer(), skipFailures: true)

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let titleResult = dictionary[titleName].map(titleTransformer.transform(source:)) ?? .failure(.requirement)
        let documentsListsResult = dictionary[documentsListsName].map(documentsListsTransformer.transform(source:)) ?? .failure(.requirement)

        var errors: [(String, TransformerError)] = []
        titleResult.error.map { errors.append((titleName, $0)) }
        documentsListsResult.error.map { errors.append((documentsListsName, $0)) }

        guard
            let title = titleResult.value,
            let documentsLists = documentsListsResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                title: title,
                documentsLists: documentsLists
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let titleResult = titleTransformer.transform(destination: value.title)
        let documentsListsResult = documentsListsTransformer.transform(destination: value.documentsLists)

        var errors: [(String, TransformerError)] = []
        titleResult.error.map { errors.append((titleName, $0)) }
        documentsListsResult.error.map { errors.append((documentsListsName, $0)) }

        guard
            let title = titleResult.value,
            let documentsLists = documentsListsResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[titleName] = title
        dictionary[documentsListsName] = documentsLists
        return .success(dictionary)
    }
}
