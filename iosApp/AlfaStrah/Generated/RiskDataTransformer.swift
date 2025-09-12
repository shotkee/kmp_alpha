// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct RiskDataTransformer: Transformer {
    typealias Source = Any
    typealias Destination = RiskData

    let idName = "id"
    let kindName = "type"
    let titleName = "title"
    let titleOptionsName = "title_options"
    let requiredStatusName = "is_required"
    let optionsName = "risk_data_option_list"
    let validSymbolsName = "available_symbols"
    let maxSymbolsLengthName = "max_length"

    let idTransformer = IdTransformer<Any>()
    let kindTransformer = RiskDataRiskDataKindTransformer()
    let titleTransformer = OptionalTransformer(transformer: CastTransformer<Any, String>())
    let titleOptionsTransformer = OptionalTransformer(transformer: CastTransformer<Any, String>())
    let requiredStatusTransformer = RiskDataRequiredStatusTransformer()
    let optionsTransformer = OptionalTransformer(transformer: ArrayTransformer(from: Any.self, transformer: RiskDataOptionTransformer(), skipFailures: true))
    let validSymbolsTransformer = OptionalTransformer(transformer: ArrayTransformer(from: Any.self, transformer: CastTransformer<Any, String>(), skipFailures: true))
    let maxSymbolsLengthTransformer = OptionalTransformer(transformer: NumberTransformer<Any, Int>())

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let idResult = dictionary[idName].map(idTransformer.transform(source:)) ?? .failure(.requirement)
        let kindResult = dictionary[kindName].map(kindTransformer.transform(source:)) ?? .failure(.requirement)
        let titleResult = titleTransformer.transform(source: dictionary[titleName])
        let titleOptionsResult = titleOptionsTransformer.transform(source: dictionary[titleOptionsName])
        let requiredStatusResult = dictionary[requiredStatusName].map(requiredStatusTransformer.transform(source:)) ?? .failure(.requirement)
        let optionsResult = optionsTransformer.transform(source: dictionary[optionsName])
        let validSymbolsResult = validSymbolsTransformer.transform(source: dictionary[validSymbolsName])
        let maxSymbolsLengthResult = maxSymbolsLengthTransformer.transform(source: dictionary[maxSymbolsLengthName])

        var errors: [(String, TransformerError)] = []
        idResult.error.map { errors.append((idName, $0)) }
        kindResult.error.map { errors.append((kindName, $0)) }
        titleResult.error.map { errors.append((titleName, $0)) }
        titleOptionsResult.error.map { errors.append((titleOptionsName, $0)) }
        requiredStatusResult.error.map { errors.append((requiredStatusName, $0)) }
        optionsResult.error.map { errors.append((optionsName, $0)) }
        validSymbolsResult.error.map { errors.append((validSymbolsName, $0)) }
        maxSymbolsLengthResult.error.map { errors.append((maxSymbolsLengthName, $0)) }

        guard
            let id = idResult.value,
            let kind = kindResult.value,
            let title = titleResult.value,
            let titleOptions = titleOptionsResult.value,
            let requiredStatus = requiredStatusResult.value,
            let options = optionsResult.value,
            let validSymbols = validSymbolsResult.value,
            let maxSymbolsLength = maxSymbolsLengthResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                id: id,
                kind: kind,
                title: title,
                titleOptions: titleOptions,
                requiredStatus: requiredStatus,
                options: options,
                validSymbols: validSymbols,
                maxSymbolsLength: maxSymbolsLength
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let idResult = idTransformer.transform(destination: value.id)
        let kindResult = kindTransformer.transform(destination: value.kind)
        let titleResult = titleTransformer.transform(destination: value.title)
        let titleOptionsResult = titleOptionsTransformer.transform(destination: value.titleOptions)
        let requiredStatusResult = requiredStatusTransformer.transform(destination: value.requiredStatus)
        let optionsResult = optionsTransformer.transform(destination: value.options)
        let validSymbolsResult = validSymbolsTransformer.transform(destination: value.validSymbols)
        let maxSymbolsLengthResult = maxSymbolsLengthTransformer.transform(destination: value.maxSymbolsLength)

        var errors: [(String, TransformerError)] = []
        idResult.error.map { errors.append((idName, $0)) }
        kindResult.error.map { errors.append((kindName, $0)) }
        titleResult.error.map { errors.append((titleName, $0)) }
        titleOptionsResult.error.map { errors.append((titleOptionsName, $0)) }
        requiredStatusResult.error.map { errors.append((requiredStatusName, $0)) }
        optionsResult.error.map { errors.append((optionsName, $0)) }
        validSymbolsResult.error.map { errors.append((validSymbolsName, $0)) }
        maxSymbolsLengthResult.error.map { errors.append((maxSymbolsLengthName, $0)) }

        guard
            let id = idResult.value,
            let kind = kindResult.value,
            let title = titleResult.value,
            let titleOptions = titleOptionsResult.value,
            let requiredStatus = requiredStatusResult.value,
            let options = optionsResult.value,
            let validSymbols = validSymbolsResult.value,
            let maxSymbolsLength = maxSymbolsLengthResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[idName] = id
        dictionary[kindName] = kind
        dictionary[titleName] = title
        dictionary[titleOptionsName] = titleOptions
        dictionary[requiredStatusName] = requiredStatus
        dictionary[optionsName] = options
        dictionary[validSymbolsName] = validSymbols
        dictionary[maxSymbolsLengthName] = maxSymbolsLength
        return .success(dictionary)
    }
}
