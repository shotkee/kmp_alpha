// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct AppNotificationResponseTransformer: Transformer {
    typealias Source = Any
    typealias Destination = AppNotificationResponse

    let notificationListName = "notification_list"
    let totalMessageCountName = "total_cnt"
    let unreadMessageCountName = "unread_cnt"

    let notificationListTransformer = ArrayTransformer(from: Any.self, transformer: AppNotificationTransformer(), skipFailures: true)
    let totalMessageCountTransformer = NumberTransformer<Any, Int>()
    let unreadMessageCountTransformer = NumberTransformer<Any, Int>()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let notificationListResult = dictionary[notificationListName].map(notificationListTransformer.transform(source:)) ?? .failure(.requirement)
        let totalMessageCountResult = dictionary[totalMessageCountName].map(totalMessageCountTransformer.transform(source:)) ?? .failure(.requirement)
        let unreadMessageCountResult = dictionary[unreadMessageCountName].map(unreadMessageCountTransformer.transform(source:)) ?? .failure(.requirement)

        var errors: [(String, TransformerError)] = []
        notificationListResult.error.map { errors.append((notificationListName, $0)) }
        totalMessageCountResult.error.map { errors.append((totalMessageCountName, $0)) }
        unreadMessageCountResult.error.map { errors.append((unreadMessageCountName, $0)) }

        guard
            let notificationList = notificationListResult.value,
            let totalMessageCount = totalMessageCountResult.value,
            let unreadMessageCount = unreadMessageCountResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                notificationList: notificationList,
                totalMessageCount: totalMessageCount,
                unreadMessageCount: unreadMessageCount
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let notificationListResult = notificationListTransformer.transform(destination: value.notificationList)
        let totalMessageCountResult = totalMessageCountTransformer.transform(destination: value.totalMessageCount)
        let unreadMessageCountResult = unreadMessageCountTransformer.transform(destination: value.unreadMessageCount)

        var errors: [(String, TransformerError)] = []
        notificationListResult.error.map { errors.append((notificationListName, $0)) }
        totalMessageCountResult.error.map { errors.append((totalMessageCountName, $0)) }
        unreadMessageCountResult.error.map { errors.append((unreadMessageCountName, $0)) }

        guard
            let notificationList = notificationListResult.value,
            let totalMessageCount = totalMessageCountResult.value,
            let unreadMessageCount = unreadMessageCountResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[notificationListName] = notificationList
        dictionary[totalMessageCountName] = totalMessageCount
        dictionary[unreadMessageCountName] = unreadMessageCount
        return .success(dictionary)
    }
}
