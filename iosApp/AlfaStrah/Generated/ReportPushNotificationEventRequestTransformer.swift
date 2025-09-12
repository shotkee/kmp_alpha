// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct ReportPushNotificationEventRequestTransformer: Transformer {
    typealias Source = Any
    typealias Destination = ReportPushNotificationEventRequest

    let eventName = "event_type_id"
    let externalNotificationIdName = "external_id"

    let eventTransformer = PushNotificationEventTransformer()
    let externalNotificationIdTransformer = CastTransformer<Any, String>()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let eventResult = dictionary[eventName].map(eventTransformer.transform(source:)) ?? .failure(.requirement)
        let externalNotificationIdResult = dictionary[externalNotificationIdName].map(externalNotificationIdTransformer.transform(source:)) ?? .failure(.requirement)

        var errors: [(String, TransformerError)] = []
        eventResult.error.map { errors.append((eventName, $0)) }
        externalNotificationIdResult.error.map { errors.append((externalNotificationIdName, $0)) }

        guard
            let event = eventResult.value,
            let externalNotificationId = externalNotificationIdResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                event: event,
                externalNotificationId: externalNotificationId
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let eventResult = eventTransformer.transform(destination: value.event)
        let externalNotificationIdResult = externalNotificationIdTransformer.transform(destination: value.externalNotificationId)

        var errors: [(String, TransformerError)] = []
        eventResult.error.map { errors.append((eventName, $0)) }
        externalNotificationIdResult.error.map { errors.append((externalNotificationIdName, $0)) }

        guard
            let event = eventResult.value,
            let externalNotificationId = externalNotificationIdResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[eventName] = event
        dictionary[externalNotificationIdName] = externalNotificationId
        return .success(dictionary)
    }
}
