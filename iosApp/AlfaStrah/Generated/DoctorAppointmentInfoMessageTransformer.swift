// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct DoctorAppointmentInfoMessageTransformer: Transformer {
    typealias Source = Any
    typealias Destination = DoctorAppointmentInfoMessage

    let typeName = "type"
    let titleName = "title"
    let textName = "text"
    let iconName = "icon"
    let actionsName = "actions"

    let typeTransformer = DoctorAppointmentInfoMessageMessageTypeTransformer()
    let titleTransformer = CastTransformer<Any, String>()
    let textTransformer = CastTransformer<Any, String>()
    let iconTransformer = OptionalTransformer(transformer: UrlTransformer<Any>())
    let actionsTransformer = ArrayTransformer(from: Any.self, transformer: DoctorAppointmentInfoMessageActionTransformer(), skipFailures: true)

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let typeResult = dictionary[typeName].map(typeTransformer.transform(source:)) ?? .failure(.requirement)
        let titleResult = dictionary[titleName].map(titleTransformer.transform(source:)) ?? .failure(.requirement)
        let textResult = dictionary[textName].map(textTransformer.transform(source:)) ?? .failure(.requirement)
        let iconResult = iconTransformer.transform(source: dictionary[iconName])
        let actionsResult = dictionary[actionsName].map(actionsTransformer.transform(source:)) ?? .failure(.requirement)

        var errors: [(String, TransformerError)] = []
        typeResult.error.map { errors.append((typeName, $0)) }
        titleResult.error.map { errors.append((titleName, $0)) }
        textResult.error.map { errors.append((textName, $0)) }
        iconResult.error.map { errors.append((iconName, $0)) }
        actionsResult.error.map { errors.append((actionsName, $0)) }

        guard
            let type = typeResult.value,
            let title = titleResult.value,
            let text = textResult.value,
            let icon = iconResult.value,
            let actions = actionsResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                type: type,
                title: title,
                text: text,
                icon: icon,
                actions: actions
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let typeResult = typeTransformer.transform(destination: value.type)
        let titleResult = titleTransformer.transform(destination: value.title)
        let textResult = textTransformer.transform(destination: value.text)
        let iconResult = iconTransformer.transform(destination: value.icon)
        let actionsResult = actionsTransformer.transform(destination: value.actions)

        var errors: [(String, TransformerError)] = []
        typeResult.error.map { errors.append((typeName, $0)) }
        titleResult.error.map { errors.append((titleName, $0)) }
        textResult.error.map { errors.append((textName, $0)) }
        iconResult.error.map { errors.append((iconName, $0)) }
        actionsResult.error.map { errors.append((actionsName, $0)) }

        guard
            let type = typeResult.value,
            let title = titleResult.value,
            let text = textResult.value,
            let icon = iconResult.value,
            let actions = actionsResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[typeName] = type
        dictionary[titleName] = title
        dictionary[textName] = text
        dictionary[iconName] = icon
        dictionary[actionsName] = actions
        return .success(dictionary)
    }
}
