//
// NotificationsService
// AlfaStrah
//
// Created by Eugene Egorov on 20 November 2018.
// Copyright (c) 2018 RedMadRobot. All rights reserved.
//

import Legacy

struct NotificationsServiceNotify {
    var needRefreshNotifications: () -> Void
}

protocol NotificationsService: Updatable {
    var notify: NotificationsServiceNotify { get }
    func cachedMain() -> [AppNotification]
    func subscribeForUnreadMessageCountUpdates(listener: @escaping (Int) -> Void) -> Subscription
    func subscribeForNeedRefreshNotifications(listener: @escaping () -> Void) -> Subscription
    func main(completion: @escaping (Result<AppNotificationResponse, AlfastrahError>) -> Void)
    func all(offset: Int, limit: Int?, completion: @escaping (Result<[AppNotification], AlfastrahError>) -> Void)
    func markAsRead(notification: AppNotification, completion: @escaping (Result<Bool, AlfastrahError>) -> Void)
    func delete(notification: AppNotification, completion: @escaping (Result<Bool, AlfastrahError>) -> Void)
    func updateUnreadMessagesCount()
    func unreadNotificationsCounter(completion: @escaping (Result<Int, AlfastrahError>) -> Void)
    func backendNotifications(
        fromId: Int?,
        count: Int,
        completion: @escaping (Result<BackendNotificationsResponse, AlfastrahError>) -> Void
    )
    func readBackendNotifications(with ids: [Int], completion: @escaping (Result<Void, AlfastrahError>) -> Void)
    func readAllBackendNotifications(topNotificationId: Int, completion: @escaping (Result<Void, AlfastrahError>) -> Void)
}
