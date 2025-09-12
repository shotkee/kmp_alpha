// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct BackendNotificationsResponseTransformer: Transformer {
    typealias Source = Any
    typealias Destination = BackendNotificationsResponse

    let notificationsName = "notification_list"
    let remainingCounterName = "left_cnt"

    let notificationsTransformer = ArrayTransformer(from: Any.self, transformer: BackendNotificationTransformer(), skipFailures: true)
    let remainingCounterTransformer = NumberTransformer<Any, Int>()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let notificationsResult = dictionary[notificationsName].map(notificationsTransformer.transform(source:)) ?? .failure(.requirement)
        let remainingCounterResult = dictionary[remainingCounterName].map(remainingCounterTransformer.transform(source:)) ?? .failure(.requirement)

        var errors: [(String, TransformerError)] = []
        notificationsResult.error.map { errors.append((notificationsName, $0)) }
        remainingCounterResult.error.map { errors.append((remainingCounterName, $0)) }

        guard
            let notifications = notificationsResult.value,
            let remainingCounter = remainingCounterResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                notifications: notifications,
                remainingCounter: remainingCounter
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let notificationsResult = notificationsTransformer.transform(destination: value.notifications)
        let remainingCounterResult = remainingCounterTransformer.transform(destination: value.remainingCounter)

        var errors: [(String, TransformerError)] = []
        notificationsResult.error.map { errors.append((notificationsName, $0)) }
        remainingCounterResult.error.map { errors.append((remainingCounterName, $0)) }

        guard
            let notifications = notificationsResult.value,
            let remainingCounter = remainingCounterResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[notificationsName] = notifications
        dictionary[remainingCounterName] = remainingCounter
        return .success(dictionary)
    }
}
