//
//  DeviceNotificationsService
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 16/10/2018.
//  Copyright © 2018 RedMadRobot. All rights reserved.
//

import UIKit
import UserNotifications
import Legacy

class DeviceNotificationsService: LocalNotificationsService, Updatable {
    private let applicationSettingsService: ApplicationSettingsService

    lazy var logger: TaggedLogger = SimpleTaggedLogger(logger: PrintLogger(), for: self)

    init(applicationSettingsService: ApplicationSettingsService) {
        self.applicationSettingsService = applicationSettingsService
    }

    func createLocalNotification(kind: LocalNotificationKind) {
        center.getNotificationSettings { settings in
            guard settings.authorizationStatus == .authorized else { return }

            self.scheduleNotification(kind: kind)
        }
    }

    func process(notification: UNNotification) -> LocalNotificationKind {
        guard let notificationKind = LocalNotificationKind.from(notification.request.content.userInfo) else { return .none }

        let notificationIds = notificationKind.fireInfo.map { $0.id }
        center.removeDeliveredNotifications(withIdentifiers: notificationIds)
        return notificationKind
    }

    func removeNotifications(kind: LocalNotificationKind) {
        let notificationIds = kind.fireInfo.map { $0.id }
        center.removePendingNotificationRequests(withIdentifiers: notificationIds)
        center.removeDeliveredNotifications(withIdentifiers: notificationIds)
    }

    private let center = UNUserNotificationCenter.current()

    private func scheduleNotification(kind: LocalNotificationKind) {
        let content = UNMutableNotificationContent()
        content.body = kind.message
        content.sound = .default
        content.threadIdentifier = kind.threadIdentifier
        content.userInfo = kind.userInfo
        
        for fireInfo in kind.fireInfo {
            let trigger = fireInfo.interval.map { UNTimeIntervalNotificationTrigger(timeInterval: $0, repeats: false) }
            let request = UNNotificationRequest(identifier: fireInfo.id, content: content, trigger: trigger)
            
            center.add(request) { error in
                if error != nil {
                    self.logger.error(String(describing: error))
                }
            }
        }
    }

    // MARK: - Updatable

    func updateService(isUserAuthorized: Bool, completion: @escaping (Result<Void, ServiceUpdateError>) -> Void) {
        completion(.failure(.notImplemented))
    }

    func performActionAfterAppIsReady(isUserAuthorized: Bool, completion: @escaping (Result<Void, ServiceUpdateError>) -> Void) {
        completion(.failure(.notImplemented))
    }

    func erase(logout: Bool) {
        LocalNotificationKind.allCases.forEach(removeNotifications)
    }
}

private extension LocalNotificationKind {
    var message: String {
        switch self {
            case .draftIncompleteVehicle, .draftIncompletePassenger:
                return NSLocalizedString("local_notification_draft_incomplete", comment: "")
            case .leftCountry:
                return NSLocalizedString("vzr_on_off_cross_border_notification_text", comment: "")
            case .none:
                return ""
        }
    }

    private enum Constants {
        static let kindKey: String = "kind"
    }

    var userInfo: [AnyHashable: Any] {
        [ Constants.kindKey: rawValue ]
    }

    struct FireInfo {
        var id: String
        var interval: TimeInterval?
    }

    var threadIdentifier: String {
        switch self {
            case .draftIncompleteVehicle, .draftIncompletePassenger:
                return "autoDraft"
            case .leftCountry:
                return "vzrOnOff"
            case .none:
                return "none"
        }
    }

    var fireInfo: [FireInfo] {
        switch self {
            case .draftIncompleteVehicle, .draftIncompletePassenger:
                let oneHour: TimeInterval = 1 * 60 * 60
                return [
                    FireInfo(id: "\(rawValue)_first", interval: oneHour),
                    FireInfo(id: "\(rawValue)_second", interval: 24 * oneHour),
                ]
            case .leftCountry, .none:
                return [ FireInfo(id: "\(rawValue)", interval: nil) ]
        }
    }
}

extension LocalNotificationKind {
    static func from(_ userInfo: [AnyHashable: Any]) -> LocalNotificationKind? {
        (userInfo[Constants.kindKey] as? RawValue).flatMap(LocalNotificationKind.init)
    }
}
