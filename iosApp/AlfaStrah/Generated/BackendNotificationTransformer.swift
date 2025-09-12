// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct BackendNotificationTransformer: Transformer {
    typealias Source = Any
    typealias Destination = BackendNotification

    let idName = "notification_id"
    let dateName = "datetime_created"
    let titleName = "title"
    let descriptionName = "description"
    let statusName = "status"
    let actionName = "action"

    let idTransformer = NumberTransformer<Any, Int>()
    let dateTransformer = DateTransformer<Any>()
    let titleTransformer = CastTransformer<Any, String>()
    let descriptionTransformer = CastTransformer<Any, String>()
    let statusTransformer = BackendNotificationStatusTransformer()
    let actionTransformer = OptionalTransformer(transformer: BackendActionTransformer())

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let idResult = dictionary[idName].map(idTransformer.transform(source:)) ?? .failure(.requirement)
        let dateResult = dictionary[dateName].map(dateTransformer.transform(source:)) ?? .failure(.requirement)
        let titleResult = dictionary[titleName].map(titleTransformer.transform(source:)) ?? .failure(.requirement)
        let descriptionResult = dictionary[descriptionName].map(descriptionTransformer.transform(source:)) ?? .failure(.requirement)
        let statusResult = dictionary[statusName].map(statusTransformer.transform(source:)) ?? .failure(.requirement)
        let actionResult = actionTransformer.transform(source: dictionary[actionName])

        var errors: [(String, TransformerError)] = []
        idResult.error.map { errors.append((idName, $0)) }
        dateResult.error.map { errors.append((dateName, $0)) }
        titleResult.error.map { errors.append((titleName, $0)) }
        descriptionResult.error.map { errors.append((descriptionName, $0)) }
        statusResult.error.map { errors.append((statusName, $0)) }
        actionResult.error.map { errors.append((actionName, $0)) }

        guard
            let id = idResult.value,
            let date = dateResult.value,
            let title = titleResult.value,
            let description = descriptionResult.value,
            let status = statusResult.value,
            let action = actionResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                id: id,
                date: date,
                title: title,
                description: description,
                status: status,
                action: action
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let idResult = idTransformer.transform(destination: value.id)
        let dateResult = dateTransformer.transform(destination: value.date)
        let titleResult = titleTransformer.transform(destination: value.title)
        let descriptionResult = descriptionTransformer.transform(destination: value.description)
        let statusResult = statusTransformer.transform(destination: value.status)
        let actionResult = actionTransformer.transform(destination: value.action)

        var errors: [(String, TransformerError)] = []
        idResult.error.map { errors.append((idName, $0)) }
        dateResult.error.map { errors.append((dateName, $0)) }
        titleResult.error.map { errors.append((titleName, $0)) }
        descriptionResult.error.map { errors.append((descriptionName, $0)) }
        statusResult.error.map { errors.append((statusName, $0)) }
        actionResult.error.map { errors.append((actionName, $0)) }

        guard
            let id = idResult.value,
            let date = dateResult.value,
            let title = titleResult.value,
            let description = descriptionResult.value,
            let status = statusResult.value,
            let action = actionResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[idName] = id
        dictionary[dateName] = date
        dictionary[titleName] = title
        dictionary[descriptionName] = description
        dictionary[statusName] = status
        dictionary[actionName] = action
        return .success(dictionary)
    }
}
