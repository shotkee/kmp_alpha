//
//  LocalNotificationsService
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 16/10/2018.
//  Copyright © 2018 RedMadRobot. All rights reserved.
//

import UserNotifications

enum LocalNotificationKind: Int, CaseIterable {
    case none = 0
    case draftIncompleteVehicle = 10000
    case draftIncompletePassenger = 10001
    case leftCountry = 10005
}

protocol LocalNotificationsService {
    func createLocalNotification(kind: LocalNotificationKind)
    func process(notification: UNNotification) -> LocalNotificationKind
    func removeNotifications(kind: LocalNotificationKind)
}
