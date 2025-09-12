// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct InsuranceProductDetailedContentTransformer: Transformer {
    typealias Source = Any
    typealias Destination = InsuranceProductDetailedContent

    let contentTypeName = "type"
    let dataName = "data"

    let contentTypeTransformer = InsuranceProductDetailedContentContentTypeTransformer()
    let dataTransformer = InsuranceProductDetailedContentDataTransformer()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let contentTypeResult = dictionary[contentTypeName].map(contentTypeTransformer.transform(source:)) ?? .failure(.requirement)
        let dataResult = dictionary[dataName].map(dataTransformer.transform(source:)) ?? .failure(.requirement)

        var errors: [(String, TransformerError)] = []
        contentTypeResult.error.map { errors.append((contentTypeName, $0)) }
        dataResult.error.map { errors.append((dataName, $0)) }

        guard
            let contentType = contentTypeResult.value,
            let data = dataResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                contentType: contentType,
                data: data
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let contentTypeResult = contentTypeTransformer.transform(destination: value.contentType)
        let dataResult = dataTransformer.transform(destination: value.data)

        var errors: [(String, TransformerError)] = []
        contentTypeResult.error.map { errors.append((contentTypeName, $0)) }
        dataResult.error.map { errors.append((dataName, $0)) }

        guard
            let contentType = contentTypeResult.value,
            let data = dataResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[contentTypeName] = contentType
        dictionary[dataName] = data
        return .success(dictionary)
    }
}
