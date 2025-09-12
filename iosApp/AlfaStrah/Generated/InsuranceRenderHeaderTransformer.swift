// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct InsuranceRenderHeaderTransformer: Transformer {
    typealias Source = Any
    typealias Destination = InsuranceRenderHeader

    let valueName = "value"
    let nameName = "header"

    let valueTransformer = CastTransformer<Any, String>()
    let nameTransformer = CastTransformer<Any, String>()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let valueResult = dictionary[valueName].map(valueTransformer.transform(source:)) ?? .failure(.requirement)
        let nameResult = dictionary[nameName].map(nameTransformer.transform(source:)) ?? .failure(.requirement)

        var errors: [(String, TransformerError)] = []
        valueResult.error.map { errors.append((valueName, $0)) }
        nameResult.error.map { errors.append((nameName, $0)) }

        guard
            let value = valueResult.value,
            let name = nameResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                value: value,
                name: name
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let valueResult = valueTransformer.transform(destination: value.value)
        let nameResult = nameTransformer.transform(destination: value.name)

        var errors: [(String, TransformerError)] = []
        valueResult.error.map { errors.append((valueName, $0)) }
        nameResult.error.map { errors.append((nameName, $0)) }

        guard
            let value = valueResult.value,
            let name = nameResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[valueName] = value
        dictionary[nameName] = name
        return .success(dictionary)
    }
}
