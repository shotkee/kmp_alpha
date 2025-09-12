// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct InteractiveSupportQuestionnaireResultContentTransformer: Transformer {
    typealias Source = Any
    typealias Destination = InteractiveSupportQuestionnaireResultContent

    let internalContentTypeName = "type"
    let additionalParametersName = "data"

    let internalContentTypeTransformer = InteractiveSupportQuestionnaireResultContentInternalContentTypeTransformer()
    let additionalParametersTransformer = OptionalTransformer(transformer: DictionaryTransformer(from: Any.self, keyTransformer: CastTransformer<AnyHashable, String>(), valueTransformer: CastTransformer<Any, Any>(), skipFailures: true))

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let internalContentTypeResult = dictionary[internalContentTypeName].map(internalContentTypeTransformer.transform(source:)) ?? .failure(.requirement)
        let additionalParametersResult = additionalParametersTransformer.transform(source: dictionary[additionalParametersName])

        var errors: [(String, TransformerError)] = []
        internalContentTypeResult.error.map { errors.append((internalContentTypeName, $0)) }
        additionalParametersResult.error.map { errors.append((additionalParametersName, $0)) }

        guard
            let internalContentType = internalContentTypeResult.value,
            let additionalParameters = additionalParametersResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                internalContentType: internalContentType,
                additionalParameters: additionalParameters
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let internalContentTypeResult = internalContentTypeTransformer.transform(destination: value.internalContentType)
        let additionalParametersResult = additionalParametersTransformer.transform(destination: value.additionalParameters)

        var errors: [(String, TransformerError)] = []
        internalContentTypeResult.error.map { errors.append((internalContentTypeName, $0)) }
        additionalParametersResult.error.map { errors.append((additionalParametersName, $0)) }

        guard
            let internalContentType = internalContentTypeResult.value,
            let additionalParameters = additionalParametersResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[internalContentTypeName] = internalContentType
        dictionary[additionalParametersName] = additionalParameters
        return .success(dictionary)
    }
}
