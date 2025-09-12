// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct BackendActionTransformer: Transformer {
    typealias Source = Any
    typealias Destination = BackendAction

    let titleName = "action_title"
    let internalTypeName = "action_type"
    let additionalParametersName = "action_info"

    let titleTransformer = CastTransformer<Any, String>()
    let internalTypeTransformer = BackendActionInternalActionTypeTransformer()
    let additionalParametersTransformer = OptionalTransformer(transformer: DictionaryTransformer(from: Any.self, keyTransformer: CastTransformer<AnyHashable, String>(), valueTransformer: CastTransformer<Any, Any>(), skipFailures: true))

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let titleResult = dictionary[titleName].map(titleTransformer.transform(source:)) ?? .failure(.requirement)
        let internalTypeResult = dictionary[internalTypeName].map(internalTypeTransformer.transform(source:)) ?? .failure(.requirement)
        let additionalParametersResult = additionalParametersTransformer.transform(source: dictionary[additionalParametersName])

        var errors: [(String, TransformerError)] = []
        titleResult.error.map { errors.append((titleName, $0)) }
        internalTypeResult.error.map { errors.append((internalTypeName, $0)) }
        additionalParametersResult.error.map { errors.append((additionalParametersName, $0)) }

        guard
            let title = titleResult.value,
            let internalType = internalTypeResult.value,
            let additionalParameters = additionalParametersResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                title: title,
                internalType: internalType,
                additionalParameters: additionalParameters
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let titleResult = titleTransformer.transform(destination: value.title)
        let internalTypeResult = internalTypeTransformer.transform(destination: value.internalType)
        let additionalParametersResult = additionalParametersTransformer.transform(destination: value.additionalParameters)

        var errors: [(String, TransformerError)] = []
        titleResult.error.map { errors.append((titleName, $0)) }
        internalTypeResult.error.map { errors.append((internalTypeName, $0)) }
        additionalParametersResult.error.map { errors.append((additionalParametersName, $0)) }

        guard
            let title = titleResult.value,
            let internalType = internalTypeResult.value,
            let additionalParameters = additionalParametersResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[titleName] = title
        dictionary[internalTypeName] = internalType
        dictionary[additionalParametersName] = additionalParameters
        return .success(dictionary)
    }
}
