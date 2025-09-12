// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct RiskDataDependencyTransformer: Transformer {
    typealias Source = Any
    typealias Destination = RiskDataDependency

    let checkboxIdName = "risk_data_id_checkbox"
    let optionIdName = "risk_data_option_id"

    let checkboxIdTransformer = OptionalTransformer(transformer: IdTransformer<Any>())
    let optionIdTransformer = OptionalTransformer(transformer: IdTransformer<Any>())

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let checkboxIdResult = checkboxIdTransformer.transform(source: dictionary[checkboxIdName])
        let optionIdResult = optionIdTransformer.transform(source: dictionary[optionIdName])

        var errors: [(String, TransformerError)] = []
        checkboxIdResult.error.map { errors.append((checkboxIdName, $0)) }
        optionIdResult.error.map { errors.append((optionIdName, $0)) }

        guard
            let checkboxId = checkboxIdResult.value,
            let optionId = optionIdResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                checkboxId: checkboxId,
                optionId: optionId
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let checkboxIdResult = checkboxIdTransformer.transform(destination: value.checkboxId)
        let optionIdResult = optionIdTransformer.transform(destination: value.optionId)

        var errors: [(String, TransformerError)] = []
        checkboxIdResult.error.map { errors.append((checkboxIdName, $0)) }
        optionIdResult.error.map { errors.append((optionIdName, $0)) }

        guard
            let checkboxId = checkboxIdResult.value,
            let optionId = optionIdResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[checkboxIdName] = checkboxId
        dictionary[optionIdName] = optionId
        return .success(dictionary)
    }
}
