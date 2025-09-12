//
//  BackendNotification.swift
//  AlfaStrah
//
//  Created by vit on 09.10.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

// sourcery: transformer
struct BackendNotification {
    // sourcery: transformer.name = "notification_id"
    let id: Int
    // sourcery: transformer.name = "datetime_created", transformer = "DateTransformer<Any>()"
    let date: Date
    // sourcery: transformer.name = "title"
    let title: String
    // sourcery: transformer.name = "description"
    let description: String
    
    // sourcery: enumTransformer, enumTransformer.type = "String"
    enum Status: String {
        // sourcery: enumTransformer.value = "read"
        case read = "read"
        // sourcery: enumTransformer.value = "unread"
        case unread = "unread"
    }
    // sourcery: transformer.name = "status"
    var status: Status
    
    // sourcery: transformer.name = "action"
    let action: BackendAction?
}

// sourcery: transformer
struct BackendNotificationsResponse {
    // sourcery: transformer.name = "notification_list"
    let notifications: [BackendNotification]
    // sourcery: transformer.name = "left_cnt"
    let remainingCounter: Int
}
