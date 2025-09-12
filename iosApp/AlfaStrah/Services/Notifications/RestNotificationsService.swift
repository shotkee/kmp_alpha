//
// RestNotificationsService
// AlfaStrah
//
// Created by Eugene Egorov on 20 November 2018.
// Copyright (c) 2018 RedMadRobot. All rights reserved.
//

import Legacy

class RestNotificationsService: NotificationsService {
    private(set) lazy var notify: NotificationsServiceNotify = .init(
        needRefreshNotifications: { [weak self] in
            self?.needRefreshNotificationsSubscriptions.fire(())
        }
    )

    private let rest: FullRestClient
    private let store: Store
    private let applicationSettingsService: ApplicationSettingsService

    init(rest: FullRestClient, store: Store, applicationSettingsService: ApplicationSettingsService) {
        self.rest = rest
        self.store = store
        self.applicationSettingsService = applicationSettingsService
    }

    func cachedMain() -> [AppNotification] {
        var notifications: [AppNotification] = []
        try? store.read { transaction in
            notifications = try transaction.select()
        }
        return notifications
    }

    private var unreadMessageCountSubscriptions: Subscriptions<Int> = Subscriptions()
    private var needRefreshNotificationsSubscriptions: Subscriptions<Void> = Subscriptions()

    func subscribeForUnreadMessageCountUpdates(listener: @escaping (Int) -> Void) -> Subscription {
        unreadMessageCountSubscriptions.add(listener)
    }

    func subscribeForNeedRefreshNotifications(listener: @escaping () -> Void) -> Subscription {
        needRefreshNotificationsSubscriptions.add(listener)
    }

    func main(completion: @escaping (Result<AppNotificationResponse, AlfastrahError>) -> Void) {
        rest.read(
            path: "notifications",
            id: nil,
            parameters: [:],
            headers: [:],
            responseTransformer: ResponseTransformer(transformer: AppNotificationResponseTransformer()),
            completion: mapCompletion { result in
                if case .success(let response) = result {
                    self.unreadMessageCountSubscriptions.fire(response.unreadMessageCount)
                    try? self.store.write { transaction in
                        try transaction.delete(type: AppNotification.self)
                        try transaction.insert(response.notificationList)
                    }
                }
                completion(result)
            }
        )
    }

    func all(offset: Int, limit: Int?, completion: @escaping (Result<[AppNotification], AlfastrahError>) -> Void) {
        var parameters: [String: String] = [:]
        parameters["offset"] = "\(offset)"
        parameters["limit"] = limit.map { "\($0)" }
        rest.read(
            path: "notifications/all",
            id: nil,
            parameters: parameters,
            headers: [:],
            responseTransformer: ResponseTransformer(
                key: "notification_list",
                transformer: ArrayTransformer(transformer: AppNotificationTransformer())
            ),
            completion: mapCompletion(completion)
        )
    }
    
    func backendNotifications(
        fromId: Int?,
        count: Int,
        completion: @escaping (Result<BackendNotificationsResponse, AlfastrahError>) -> Void
    ) {
        var parameters: [String: String] = [:]
        parameters["limit"] = String(count)
        
        if let fromId = fromId {
            parameters["notification_id"] = String(fromId)
        }
        
        rest.read(
            path: "api/notification/list",
            id: nil,
            parameters: parameters,
            headers: [:],
            responseTransformer: ResponseTransformer(transformer: BackendNotificationsResponseTransformer()),
            completion: mapCompletion(completion)
        )
    }
    
    func readBackendNotifications(with ids: [Int], completion: @escaping (Result<Void, AlfastrahError>) -> Void) {
        rest.create(
            path: "api/notification/read/single",
            id: nil,
            object: ["notification_ids": ids],
            headers: [:],
            requestTransformer: DictionaryTransformer(
                keyTransformer: CastTransformer<AnyHashable, String>(),
                valueTransformer: CastTransformer<Any, [Int]>()
            ),
            responseTransformer: VoidTransformer(),
            completion: mapCompletion(completion)
        )
    }
    
    func readAllBackendNotifications(topNotificationId: Int, completion: @escaping (Result<Void, AlfastrahError>) -> Void) {
        rest.create(
            path: "api/notification/read/all",
            id: nil,
            object: ["notification_id": "\(topNotificationId)"],
            headers: [:],
            requestTransformer: DictionaryTransformer(
                keyTransformer: CastTransformer<AnyHashable, String>(),
                valueTransformer: CastTransformer<Any, String>()
            ),
            responseTransformer: VoidTransformer(),
            completion: mapCompletion(completion)
        )
    }

    func markAsRead(notification: AppNotification, completion: @escaping (Result<Bool, AlfastrahError>) -> Void) {
        rest.create(
            path: "notifications/read",
            id: nil,
            object: MarkAsReadNotifications(ids: [ notification.id ]),
            headers: [:],
            requestTransformer: MarkAsReadNotificationsTransformer(),
            responseTransformer: ResponseTransformer(key: "success", transformer: CastTransformer<Any, Bool>()),
            completion: mapCompletion { result in
                if case .success(true) = result {
                    try? self.store.write { transaction in
                        if var storedNotification: AppNotification = try transaction.select(id: notification.id) {
                            storedNotification.isRead = true
                            try transaction.update(storedNotification)
                        }
                    }
                    self.notifyUnreadMessageCount()
                }
                completion(result)
            }
        )
    }

    func delete(notification: AppNotification, completion: @escaping (Result<Bool, AlfastrahError>) -> Void) {
        rest.create(
            path: "notifications",
            id: "\(notification.id)/remove/",
            object: DeleteNotification(id: notification.id, isDeleted: true),
            headers: [:],
            requestTransformer: DeleteNotificationTransformer(),
            responseTransformer: ResponseTransformer(key: "success", transformer: CastTransformer<Any, Bool>()),
            completion: mapCompletion { result in
                if case .success(true) = result {
                    try? self.store.write { transaction in
                        try transaction.delete(type: AppNotification.self, id: notification.id)
                    }
                    self.notifyUnreadMessageCount()
                }
                completion(result)
            }
        )
    }
    
    func unreadNotificationsCounter(completion: @escaping (Result<Int, AlfastrahError>) -> Void) {
        rest.read(
            path: "/api/notification/counter",
            id: nil,
            parameters: [:],
            headers: [:],
            responseTransformer: ResponseTransformer(
                key: "notification_unread_cnt",
                transformer: CastTransformer<Any, Int>()
            ),
            completion: mapCompletion(completion)
        )
    }

    func updateUnreadMessagesCount() {
        notifyUnreadMessageCount()
    }

    private func notifyUnreadMessageCount() {
        var notifications: [AppNotification] = []
        try? store.read { transaction in
            notifications = try transaction.select()
        }
        unreadMessageCountSubscriptions.fire(notifications.filter { !$0.isRead }.count)
    }

    // MARK: - Updatable

    func updateService(isUserAuthorized: Bool, completion: @escaping (Result<Void, ServiceUpdateError>) -> Void) {
        completion(.failure(.notImplemented))
    }

    func performActionAfterAppIsReady(isUserAuthorized: Bool, completion: @escaping (Result<Void, ServiceUpdateError>) -> Void) {
        completion(.failure(.notImplemented))
    }

    func erase(logout: Bool) {
        try? store.write { transaction in
            try transaction.delete(type: AppNotification.self)
        }
        applicationSettingsService.showFirstAlphaPoints = false
    }
}
