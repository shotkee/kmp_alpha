// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct InsuranceCategoryMainTransformer: Transformer {
    typealias Source = Any
    typealias Destination = InsuranceCategoryMain

    let idName = "id"
    let titleName = "title"
    let descriptionName = "description"
    let typeName = "type"
    let iconName = "icon"
    let iconThemedName = "icon_themed"

    let idTransformer = IdTransformer<Any>()
    let titleTransformer = CastTransformer<Any, String>()
    let descriptionTransformer = CastTransformer<Any, String>()
    let typeTransformer = InsuranceCategoryMainCategoryTypeTransformer()
    let iconTransformer = OptionalTransformer(transformer: CastTransformer<Any, String>())
    let iconThemedTransformer = OptionalTransformer(transformer: ThemedValueTransformer())

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let idResult = dictionary[idName].map(idTransformer.transform(source:)) ?? .failure(.requirement)
        let titleResult = dictionary[titleName].map(titleTransformer.transform(source:)) ?? .failure(.requirement)
        let descriptionResult = dictionary[descriptionName].map(descriptionTransformer.transform(source:)) ?? .failure(.requirement)
        let typeResult = dictionary[typeName].map(typeTransformer.transform(source:)) ?? .failure(.requirement)
        let iconResult = iconTransformer.transform(source: dictionary[iconName])
        let iconThemedResult = iconThemedTransformer.transform(source: dictionary[iconThemedName])

        var errors: [(String, TransformerError)] = []
        idResult.error.map { errors.append((idName, $0)) }
        titleResult.error.map { errors.append((titleName, $0)) }
        descriptionResult.error.map { errors.append((descriptionName, $0)) }
        typeResult.error.map { errors.append((typeName, $0)) }
        iconResult.error.map { errors.append((iconName, $0)) }
        iconThemedResult.error.map { errors.append((iconThemedName, $0)) }

        guard
            let id = idResult.value,
            let title = titleResult.value,
            let description = descriptionResult.value,
            let type = typeResult.value,
            let icon = iconResult.value,
            let iconThemed = iconThemedResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                id: id,
                title: title,
                description: description,
                type: type,
                icon: icon,
                iconThemed: iconThemed
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let idResult = idTransformer.transform(destination: value.id)
        let titleResult = titleTransformer.transform(destination: value.title)
        let descriptionResult = descriptionTransformer.transform(destination: value.description)
        let typeResult = typeTransformer.transform(destination: value.type)
        let iconResult = iconTransformer.transform(destination: value.icon)
        let iconThemedResult = iconThemedTransformer.transform(destination: value.iconThemed)

        var errors: [(String, TransformerError)] = []
        idResult.error.map { errors.append((idName, $0)) }
        titleResult.error.map { errors.append((titleName, $0)) }
        descriptionResult.error.map { errors.append((descriptionName, $0)) }
        typeResult.error.map { errors.append((typeName, $0)) }
        iconResult.error.map { errors.append((iconName, $0)) }
        iconThemedResult.error.map { errors.append((iconThemedName, $0)) }

        guard
            let id = idResult.value,
            let title = titleResult.value,
            let description = descriptionResult.value,
            let type = typeResult.value,
            let icon = iconResult.value,
            let iconThemed = iconThemedResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[idName] = id
        dictionary[titleName] = title
        dictionary[descriptionName] = description
        dictionary[typeName] = type
        dictionary[iconName] = icon
        dictionary[iconThemedName] = iconThemed
        return .success(dictionary)
    }
}
