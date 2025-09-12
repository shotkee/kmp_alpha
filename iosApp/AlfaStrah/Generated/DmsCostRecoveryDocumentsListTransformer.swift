// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct DmsCostRecoveryDocumentsListTransformer: Transformer {
    typealias Source = Any
    typealias Destination = DmsCostRecoveryDocumentsList

    let fullTitleName = "title"
    let shortTitleName = "label"
    let documentsName = "file_item_list"

    let fullTitleTransformer = CastTransformer<Any, String>()
    let shortTitleTransformer = CastTransformer<Any, String>()
    let documentsTransformer = ArrayTransformer(from: Any.self, transformer: DmsCostRecoveryDocumentTransformer(), skipFailures: true)

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let fullTitleResult = dictionary[fullTitleName].map(fullTitleTransformer.transform(source:)) ?? .failure(.requirement)
        let shortTitleResult = dictionary[shortTitleName].map(shortTitleTransformer.transform(source:)) ?? .failure(.requirement)
        let documentsResult = dictionary[documentsName].map(documentsTransformer.transform(source:)) ?? .failure(.requirement)

        var errors: [(String, TransformerError)] = []
        fullTitleResult.error.map { errors.append((fullTitleName, $0)) }
        shortTitleResult.error.map { errors.append((shortTitleName, $0)) }
        documentsResult.error.map { errors.append((documentsName, $0)) }

        guard
            let fullTitle = fullTitleResult.value,
            let shortTitle = shortTitleResult.value,
            let documents = documentsResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                fullTitle: fullTitle,
                shortTitle: shortTitle,
                documents: documents
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let fullTitleResult = fullTitleTransformer.transform(destination: value.fullTitle)
        let shortTitleResult = shortTitleTransformer.transform(destination: value.shortTitle)
        let documentsResult = documentsTransformer.transform(destination: value.documents)

        var errors: [(String, TransformerError)] = []
        fullTitleResult.error.map { errors.append((fullTitleName, $0)) }
        shortTitleResult.error.map { errors.append((shortTitleName, $0)) }
        documentsResult.error.map { errors.append((documentsName, $0)) }

        guard
            let fullTitle = fullTitleResult.value,
            let shortTitle = shortTitleResult.value,
            let documents = documentsResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[fullTitleName] = fullTitle
        dictionary[shortTitleName] = shortTitle
        dictionary[documentsName] = documents
        return .success(dictionary)
    }
}
