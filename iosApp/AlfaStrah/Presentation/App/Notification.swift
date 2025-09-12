//
//  Notification.swift
//  AlfaStrah
//
//  Created by Amir Nuriev on 8/23/19.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import UserNotifications

enum NotificationMessageKind {
    private enum Constants {
        static let deeplinkDestination = "target"
        static let payloadDictionaryKey = "aps"
        static let insuranceIdDictKey = "insurance_id"
        static let externalDestination = "url"
        static let externalNotificationId = "external_id"
        static let isMassMailing = "is_mass"
    }

    case newMessage
    case localNotification(LocalNotificationKind)
    case destination(PushNotificationDeeplinkInfo)

    init?(notificationResponse: UNNotificationResponse) {
        if Self.isChat(remoteNotification: notificationResponse.notification.request.content.userInfo) {
            self = .newMessage
        } else if let localNotificationKind = LocalNotificationKind.from(notificationResponse.notification.request.content.userInfo),
                localNotificationKind != .none {
            self = .localNotification(localNotificationKind)
        } else {
            guard let payload = Self.payloadDictionary(from: notificationResponse.notification),
                  let deeplinkTargetId = payload[Constants.deeplinkDestination]
                        .map(IdTransformer<Any>().transform(source:))?.value,
                  let deeplinkTarget = Int(deeplinkTargetId)
            else { return nil }

            if let deeplinkDestination = DeeplinkDestination(rawValue: deeplinkTarget) {
                let insuranceId = payload[Constants.insuranceIdDictKey] as? String
                let isMassMailing = payload[Constants.isMassMailing] as? Bool
                
                if deeplinkDestination == .externalUrl {
                    guard let externalDestinationUrlString = payload[Constants.externalDestination] as? String,
                          let externalDestinationUrl = URL(string: externalDestinationUrlString)
                    else { return nil }

                    self = .destination(
                        .init(
                            destination: deeplinkDestination,
                            insuranceId: insuranceId,
                            url: externalDestinationUrl,
                            isMassMailing: isMassMailing
                        )
                    )
                } else {
                    self = .destination(.init(destination: deeplinkDestination, insuranceId: insuranceId, url: nil, isMassMailing: nil))
                }
            } else {
                return nil
            }
        }
    }
    
    static func isChat(remoteNotification: [AnyHashable: Any]) -> Bool {
        return false // TODO: Implementation
    }

    static func externalNotificationId(from notification: UNNotification) -> String? {
        return Self.payloadDictionary(from: notification)
            .flatMap { $0[Constants.externalNotificationId] as? String }
    }

    private static func payloadDictionary(from notification: UNNotification) -> [AnyHashable: Any]? {
        return notification.request.content.userInfo[Constants.payloadDictionaryKey] as? [AnyHashable: Any]
    }
}
