// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct RiskValueTransformer: Transformer {
    typealias Source = Any
    typealias Destination = RiskValue

    let riskIdName = "risk_id"
    let categoryIdName = "risk_category_id"
    let dataIdName = "risk_data_id"
    let optionIdName = "risk_option_id"
    let valueName = "value"

    let riskIdTransformer = CastTransformer<Any, String>()
    let categoryIdTransformer = CastTransformer<Any, String>()
    let dataIdTransformer = CastTransformer<Any, String>()
    let optionIdTransformer = OptionalTransformer(transformer: CastTransformer<Any, String>())
    let valueTransformer = CastTransformer<Any, String>()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let riskIdResult = dictionary[riskIdName].map(riskIdTransformer.transform(source:)) ?? .failure(.requirement)
        let categoryIdResult = dictionary[categoryIdName].map(categoryIdTransformer.transform(source:)) ?? .failure(.requirement)
        let dataIdResult = dictionary[dataIdName].map(dataIdTransformer.transform(source:)) ?? .failure(.requirement)
        let optionIdResult = optionIdTransformer.transform(source: dictionary[optionIdName])
        let valueResult = dictionary[valueName].map(valueTransformer.transform(source:)) ?? .failure(.requirement)

        var errors: [(String, TransformerError)] = []
        riskIdResult.error.map { errors.append((riskIdName, $0)) }
        categoryIdResult.error.map { errors.append((categoryIdName, $0)) }
        dataIdResult.error.map { errors.append((dataIdName, $0)) }
        optionIdResult.error.map { errors.append((optionIdName, $0)) }
        valueResult.error.map { errors.append((valueName, $0)) }

        guard
            let riskId = riskIdResult.value,
            let categoryId = categoryIdResult.value,
            let dataId = dataIdResult.value,
            let optionId = optionIdResult.value,
            let value = valueResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                riskId: riskId,
                categoryId: categoryId,
                dataId: dataId,
                optionId: optionId,
                value: value
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let riskIdResult = riskIdTransformer.transform(destination: value.riskId)
        let categoryIdResult = categoryIdTransformer.transform(destination: value.categoryId)
        let dataIdResult = dataIdTransformer.transform(destination: value.dataId)
        let optionIdResult = optionIdTransformer.transform(destination: value.optionId)
        let valueResult = valueTransformer.transform(destination: value.value)

        var errors: [(String, TransformerError)] = []
        riskIdResult.error.map { errors.append((riskIdName, $0)) }
        categoryIdResult.error.map { errors.append((categoryIdName, $0)) }
        dataIdResult.error.map { errors.append((dataIdName, $0)) }
        optionIdResult.error.map { errors.append((optionIdName, $0)) }
        valueResult.error.map { errors.append((valueName, $0)) }

        guard
            let riskId = riskIdResult.value,
            let categoryId = categoryIdResult.value,
            let dataId = dataIdResult.value,
            let optionId = optionIdResult.value,
            let value = valueResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[riskIdName] = riskId
        dictionary[categoryIdName] = categoryId
        dictionary[dataIdName] = dataId
        dictionary[optionIdName] = optionId
        dictionary[valueName] = value
        return .success(dictionary)
    }
}
