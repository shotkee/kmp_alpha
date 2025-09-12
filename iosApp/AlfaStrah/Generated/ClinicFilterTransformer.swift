// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct ClinicFilterTransformer: Transformer {
    typealias Source = Any
    typealias Destination = ClinicFilter

    let titleName = "title"
    let iconName = "icon"
    let informationName = "information"
    let valuesName = "values"
    let renderTypeName = "render_type"

    let titleTransformer = CastTransformer<Any, String>()
    let iconTransformer = ThemedValueTransformer()
    let informationTransformer = ArrayTransformer(from: Any.self, transformer: ClinicFilterInformationTransformer(), skipFailures: true)
    let valuesTransformer = ArrayTransformer(from: Any.self, transformer: CastTransformer<Any, String>(), skipFailures: true)
    let renderTypeTransformer = ClinicFilterRenderTypeTransformer()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let titleResult = dictionary[titleName].map(titleTransformer.transform(source:)) ?? .failure(.requirement)
        let iconResult = dictionary[iconName].map(iconTransformer.transform(source:)) ?? .failure(.requirement)
        let informationResult = dictionary[informationName].map(informationTransformer.transform(source:)) ?? .failure(.requirement)
        let valuesResult = dictionary[valuesName].map(valuesTransformer.transform(source:)) ?? .failure(.requirement)
        let renderTypeResult = dictionary[renderTypeName].map(renderTypeTransformer.transform(source:)) ?? .failure(.requirement)

        var errors: [(String, TransformerError)] = []
        titleResult.error.map { errors.append((titleName, $0)) }
        iconResult.error.map { errors.append((iconName, $0)) }
        informationResult.error.map { errors.append((informationName, $0)) }
        valuesResult.error.map { errors.append((valuesName, $0)) }
        renderTypeResult.error.map { errors.append((renderTypeName, $0)) }

        guard
            let title = titleResult.value,
            let icon = iconResult.value,
            let information = informationResult.value,
            let values = valuesResult.value,
            let renderType = renderTypeResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                title: title,
                icon: icon,
                information: information,
                values: values,
                renderType: renderType
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let titleResult = titleTransformer.transform(destination: value.title)
        let iconResult = iconTransformer.transform(destination: value.icon)
        let informationResult = informationTransformer.transform(destination: value.information)
        let valuesResult = valuesTransformer.transform(destination: value.values)
        let renderTypeResult = renderTypeTransformer.transform(destination: value.renderType)

        var errors: [(String, TransformerError)] = []
        titleResult.error.map { errors.append((titleName, $0)) }
        iconResult.error.map { errors.append((iconName, $0)) }
        informationResult.error.map { errors.append((informationName, $0)) }
        valuesResult.error.map { errors.append((valuesName, $0)) }
        renderTypeResult.error.map { errors.append((renderTypeName, $0)) }

        guard
            let title = titleResult.value,
            let icon = iconResult.value,
            let information = informationResult.value,
            let values = valuesResult.value,
            let renderType = renderTypeResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[titleName] = title
        dictionary[iconName] = icon
        dictionary[informationName] = information
        dictionary[valuesName] = values
        dictionary[renderTypeName] = renderType
        return .success(dictionary)
    }
}
