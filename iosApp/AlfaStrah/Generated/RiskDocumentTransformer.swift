// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct RiskDocumentTransformer: Transformer {
    typealias Source = Any
    typealias Destination = RiskDocument

    let idName = "id"
    let titleName = "title"
    let descriptionName = "description"
    let isRequiredName = "is_required"

    let idTransformer = NumberTransformer<Any, Int>()
    let titleTransformer = CastTransformer<Any, String>()
    let descriptionTransformer = CastTransformer<Any, String>()
    let isRequiredTransformer = NumberTransformer<Any, Int>()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let idResult = dictionary[idName].map(idTransformer.transform(source:)) ?? .failure(.requirement)
        let titleResult = dictionary[titleName].map(titleTransformer.transform(source:)) ?? .failure(.requirement)
        let descriptionResult = dictionary[descriptionName].map(descriptionTransformer.transform(source:)) ?? .failure(.requirement)
        let isRequiredResult = dictionary[isRequiredName].map(isRequiredTransformer.transform(source:)) ?? .failure(.requirement)

        var errors: [(String, TransformerError)] = []
        idResult.error.map { errors.append((idName, $0)) }
        titleResult.error.map { errors.append((titleName, $0)) }
        descriptionResult.error.map { errors.append((descriptionName, $0)) }
        isRequiredResult.error.map { errors.append((isRequiredName, $0)) }

        guard
            let id = idResult.value,
            let title = titleResult.value,
            let description = descriptionResult.value,
            let isRequired = isRequiredResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                id: id,
                title: title,
                description: description,
                isRequired: isRequired
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let idResult = idTransformer.transform(destination: value.id)
        let titleResult = titleTransformer.transform(destination: value.title)
        let descriptionResult = descriptionTransformer.transform(destination: value.description)
        let isRequiredResult = isRequiredTransformer.transform(destination: value.isRequired)

        var errors: [(String, TransformerError)] = []
        idResult.error.map { errors.append((idName, $0)) }
        titleResult.error.map { errors.append((titleName, $0)) }
        descriptionResult.error.map { errors.append((descriptionName, $0)) }
        isRequiredResult.error.map { errors.append((isRequiredName, $0)) }

        guard
            let id = idResult.value,
            let title = titleResult.value,
            let description = descriptionResult.value,
            let isRequired = isRequiredResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[idName] = id
        dictionary[titleName] = title
        dictionary[descriptionName] = description
        dictionary[isRequiredName] = isRequired
        return .success(dictionary)
    }
}
