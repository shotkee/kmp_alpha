// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct EventTypeInfoTransformer: Transformer {
    typealias Source = Any
    typealias Destination = EventTypeInfo

    let idName = "id"
    let titleName = "title"
    let typeName = "type"
    let valueName = "value"
    let availableValuesName = "available_value_list"
    let isMandatoryName = "is_mandatory"
    let defaultValueName = "default_value"
    let valuesName = "value_list"
    let placeholderName = "placeholder"

    let idTransformer = IdTransformer<Any>()
    let titleTransformer = CastTransformer<Any, String>()
    let typeTransformer = EventTypeInfoKindTransformer()
    let valueTransformer = OptionalTransformer(transformer: CastTransformer<Any, String>())
    let availableValuesTransformer = OptionalTransformer(transformer: ArrayTransformer(from: Any.self, transformer: CastTransformer<Any, String>(), skipFailures: true))
    let isMandatoryTransformer = NumberTransformer<Any, Bool>()
    let defaultValueTransformer = OptionalTransformer(transformer: CastTransformer<Any, String>())
    let valuesTransformer = OptionalTransformer(transformer: ArrayTransformer(from: Any.self, transformer: CastTransformer<Any, String>(), skipFailures: true))
    let placeholderTransformer = OptionalTransformer(transformer: CastTransformer<Any, String>())

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let idResult = dictionary[idName].map(idTransformer.transform(source:)) ?? .failure(.requirement)
        let titleResult = dictionary[titleName].map(titleTransformer.transform(source:)) ?? .failure(.requirement)
        let typeResult = dictionary[typeName].map(typeTransformer.transform(source:)) ?? .failure(.requirement)
        let valueResult = valueTransformer.transform(source: dictionary[valueName])
        let availableValuesResult = availableValuesTransformer.transform(source: dictionary[availableValuesName])
        let isMandatoryResult = dictionary[isMandatoryName].map(isMandatoryTransformer.transform(source:)) ?? .failure(.requirement)
        let defaultValueResult = defaultValueTransformer.transform(source: dictionary[defaultValueName])
        let valuesResult = valuesTransformer.transform(source: dictionary[valuesName])
        let placeholderResult = placeholderTransformer.transform(source: dictionary[placeholderName])

        var errors: [(String, TransformerError)] = []
        idResult.error.map { errors.append((idName, $0)) }
        titleResult.error.map { errors.append((titleName, $0)) }
        typeResult.error.map { errors.append((typeName, $0)) }
        valueResult.error.map { errors.append((valueName, $0)) }
        availableValuesResult.error.map { errors.append((availableValuesName, $0)) }
        isMandatoryResult.error.map { errors.append((isMandatoryName, $0)) }
        defaultValueResult.error.map { errors.append((defaultValueName, $0)) }
        valuesResult.error.map { errors.append((valuesName, $0)) }
        placeholderResult.error.map { errors.append((placeholderName, $0)) }

        guard
            let id = idResult.value,
            let title = titleResult.value,
            let type = typeResult.value,
            let value = valueResult.value,
            let availableValues = availableValuesResult.value,
            let isMandatory = isMandatoryResult.value,
            let defaultValue = defaultValueResult.value,
            let values = valuesResult.value,
            let placeholder = placeholderResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                id: id,
                title: title,
                type: type,
                value: value,
                availableValues: availableValues,
                isMandatory: isMandatory,
                defaultValue: defaultValue,
                values: values,
                placeholder: placeholder
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let idResult = idTransformer.transform(destination: value.id)
        let titleResult = titleTransformer.transform(destination: value.title)
        let typeResult = typeTransformer.transform(destination: value.type)
        let valueResult = valueTransformer.transform(destination: value.value)
        let availableValuesResult = availableValuesTransformer.transform(destination: value.availableValues)
        let isMandatoryResult = isMandatoryTransformer.transform(destination: value.isMandatory)
        let defaultValueResult = defaultValueTransformer.transform(destination: value.defaultValue)
        let valuesResult = valuesTransformer.transform(destination: value.values)
        let placeholderResult = placeholderTransformer.transform(destination: value.placeholder)

        var errors: [(String, TransformerError)] = []
        idResult.error.map { errors.append((idName, $0)) }
        titleResult.error.map { errors.append((titleName, $0)) }
        typeResult.error.map { errors.append((typeName, $0)) }
        valueResult.error.map { errors.append((valueName, $0)) }
        availableValuesResult.error.map { errors.append((availableValuesName, $0)) }
        isMandatoryResult.error.map { errors.append((isMandatoryName, $0)) }
        defaultValueResult.error.map { errors.append((defaultValueName, $0)) }
        valuesResult.error.map { errors.append((valuesName, $0)) }
        placeholderResult.error.map { errors.append((placeholderName, $0)) }

        guard
            let id = idResult.value,
            let title = titleResult.value,
            let type = typeResult.value,
            let value = valueResult.value,
            let availableValues = availableValuesResult.value,
            let isMandatory = isMandatoryResult.value,
            let defaultValue = defaultValueResult.value,
            let values = valuesResult.value,
            let placeholder = placeholderResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[idName] = id
        dictionary[titleName] = title
        dictionary[typeName] = type
        dictionary[valueName] = value
        dictionary[availableValuesName] = availableValues
        dictionary[isMandatoryName] = isMandatory
        dictionary[defaultValueName] = defaultValue
        dictionary[valuesName] = values
        dictionary[placeholderName] = placeholder
        return .success(dictionary)
    }
}
