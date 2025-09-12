// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct VoipCallTransformer: Transformer {
    typealias Source = Any
    typealias Destination = VoipCall

    let titleName = "title"
    let internalTypeName = "type"
    let parametersName = "data"

    let titleTransformer = CastTransformer<Any, String>()
    let internalTypeTransformer = VoipCallInternalCallTypeTransformer()
    let parametersTransformer = OptionalTransformer(transformer: DictionaryTransformer(from: Any.self, keyTransformer: CastTransformer<AnyHashable, String>(), valueTransformer: CastTransformer<Any, Any>(), skipFailures: true))

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let titleResult = dictionary[titleName].map(titleTransformer.transform(source:)) ?? .failure(.requirement)
        let internalTypeResult = dictionary[internalTypeName].map(internalTypeTransformer.transform(source:)) ?? .failure(.requirement)
        let parametersResult = parametersTransformer.transform(source: dictionary[parametersName])

        var errors: [(String, TransformerError)] = []
        titleResult.error.map { errors.append((titleName, $0)) }
        internalTypeResult.error.map { errors.append((internalTypeName, $0)) }
        parametersResult.error.map { errors.append((parametersName, $0)) }

        guard
            let title = titleResult.value,
            let internalType = internalTypeResult.value,
            let parameters = parametersResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                title: title,
                internalType: internalType,
                parameters: parameters
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let titleResult = titleTransformer.transform(destination: value.title)
        let internalTypeResult = internalTypeTransformer.transform(destination: value.internalType)
        let parametersResult = parametersTransformer.transform(destination: value.parameters)

        var errors: [(String, TransformerError)] = []
        titleResult.error.map { errors.append((titleName, $0)) }
        internalTypeResult.error.map { errors.append((internalTypeName, $0)) }
        parametersResult.error.map { errors.append((parametersName, $0)) }

        guard
            let title = titleResult.value,
            let internalType = internalTypeResult.value,
            let parameters = parametersResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[titleName] = title
        dictionary[internalTypeName] = internalType
        dictionary[parametersName] = parameters
        return .success(dictionary)
    }
}
