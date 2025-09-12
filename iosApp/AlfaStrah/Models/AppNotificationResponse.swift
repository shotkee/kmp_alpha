//
//  AppNotificationResponse.swift
//  AlfaStrah
//
//  Created by Amir Nuriev on 09.01.2020.
//  Copyright © 2020 Redmadrobot. All rights reserved.
//

// sourcery: transformer
struct AppNotificationResponse {
    // sourcery: transformer.name = "notification_list"
    let notificationList: [AppNotification]
    // sourcery: transformer.name = "total_cnt"
    let totalMessageCount: Int
    // sourcery: transformer.name = "unread_cnt"
    let unreadMessageCount: Int
}
