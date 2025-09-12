//
//  ReportPushNotificationEventRequest.swift
//  AlfaStrah
//
//  Created by Vitaly Trofimov on 21.01.2022.
//  Copyright © 2022 Touch Instinct. All rights reserved.
//

// sourcery: transformer
struct ReportPushNotificationEventRequest {
    // sourcery: transformer.name = "event_type_id"
    let event: PushNotificationEvent

    // sourcery: transformer.name = "external_id"
    let externalNotificationId: String
}
