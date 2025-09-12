// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct InfoMessageTransformer: Transformer {
    typealias Source = Any
    typealias Destination = InfoMessage

    let actionsName = "actions"
    let typeName = "type"
    let themedIconName = "icon_themed"
    let titleTextName = "title"
    let desciptionTextName = "text"

    let actionsTransformer = OptionalTransformer(transformer: ArrayTransformer(from: Any.self, transformer: InfoMessageActionTransformer(), skipFailures: true))
    let typeTransformer = OptionalTransformer(transformer: InfoMessageTypeTransformer())
    let themedIconTransformer = OptionalTransformer(transformer: ThemedValueTransformer())
    let titleTextTransformer = OptionalTransformer(transformer: CastTransformer<Any, String>())
    let desciptionTextTransformer = OptionalTransformer(transformer: CastTransformer<Any, String>())

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let actionsResult = actionsTransformer.transform(source: dictionary[actionsName])
        let typeResult = typeTransformer.transform(source: dictionary[typeName])
        let themedIconResult = themedIconTransformer.transform(source: dictionary[themedIconName])
        let titleTextResult = titleTextTransformer.transform(source: dictionary[titleTextName])
        let desciptionTextResult = desciptionTextTransformer.transform(source: dictionary[desciptionTextName])

        var errors: [(String, TransformerError)] = []
        actionsResult.error.map { errors.append((actionsName, $0)) }
        typeResult.error.map { errors.append((typeName, $0)) }
        themedIconResult.error.map { errors.append((themedIconName, $0)) }
        titleTextResult.error.map { errors.append((titleTextName, $0)) }
        desciptionTextResult.error.map { errors.append((desciptionTextName, $0)) }

        guard
            let actions = actionsResult.value,
            let type = typeResult.value,
            let themedIcon = themedIconResult.value,
            let titleText = titleTextResult.value,
            let desciptionText = desciptionTextResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                actions: actions,
                type: type,
                themedIcon: themedIcon,
                titleText: titleText,
                desciptionText: desciptionText
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let actionsResult = actionsTransformer.transform(destination: value.actions)
        let typeResult = typeTransformer.transform(destination: value.type)
        let themedIconResult = themedIconTransformer.transform(destination: value.themedIcon)
        let titleTextResult = titleTextTransformer.transform(destination: value.titleText)
        let desciptionTextResult = desciptionTextTransformer.transform(destination: value.desciptionText)

        var errors: [(String, TransformerError)] = []
        actionsResult.error.map { errors.append((actionsName, $0)) }
        typeResult.error.map { errors.append((typeName, $0)) }
        themedIconResult.error.map { errors.append((themedIconName, $0)) }
        titleTextResult.error.map { errors.append((titleTextName, $0)) }
        desciptionTextResult.error.map { errors.append((desciptionTextName, $0)) }

        guard
            let actions = actionsResult.value,
            let type = typeResult.value,
            let themedIcon = themedIconResult.value,
            let titleText = titleTextResult.value,
            let desciptionText = desciptionTextResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[actionsName] = actions
        dictionary[typeName] = type
        dictionary[themedIconName] = themedIcon
        dictionary[titleTextName] = titleText
        dictionary[desciptionTextName] = desciptionText
        return .success(dictionary)
    }
}
