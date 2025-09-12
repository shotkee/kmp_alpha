// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct FieldListTransformer: Transformer {
    typealias Source = Any
    typealias Destination = FieldList

    let titleName = "title"
    let valueName = "value"

    let titleTransformer = CastTransformer<Any, String>()
    let valueTransformer = CastTransformer<Any, String>()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let titleResult = dictionary[titleName].map(titleTransformer.transform(source:)) ?? .failure(.requirement)
        let valueResult = dictionary[valueName].map(valueTransformer.transform(source:)) ?? .failure(.requirement)

        var errors: [(String, TransformerError)] = []
        titleResult.error.map { errors.append((titleName, $0)) }
        valueResult.error.map { errors.append((valueName, $0)) }

        guard
            let title = titleResult.value,
            let value = valueResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                title: title,
                value: value
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let titleResult = titleTransformer.transform(destination: value.title)
        let valueResult = valueTransformer.transform(destination: value.value)

        var errors: [(String, TransformerError)] = []
        titleResult.error.map { errors.append((titleName, $0)) }
        valueResult.error.map { errors.append((valueName, $0)) }

        guard
            let title = titleResult.value,
            let value = valueResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[titleName] = title
        dictionary[valueName] = value
        return .success(dictionary)
    }
}
