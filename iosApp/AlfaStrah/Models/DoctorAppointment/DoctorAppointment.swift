//
//  DoctorAppointment.swift
//  AlfaStrah
//
//  Created by vit on 20.11.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

import Foundation

// sourcery: transformer
struct DoctorAppointmentRequest {
    // sourcery: transformer.name = "insurance_id"
    let insuranceId: String
    // sourcery: transformer.name = "full_name_insured"
    let userFullame: String
    // sourcery: transformer.name = "reason"
    let symptoms: String
    // sourcery: transformer.name = "contact_phone"
    let userPhone: String
    // sourcery: transformer.name = "address"
    let userAddress: String
    // sourcery: transformer.name = "specialist"
    let doctorSpeciality: String
    // sourcery: transformer.name = "distance_type"
    let distanceType: String
    
    // sourcery: transformer.name = "sick_leave_required"
    let medicalLeaveIsRequiredTitle: String
    
    // sourcery: transformer.name = "visit_date"
    // sourcery: transformer = "DateTransformer<Any>(format: "yyyy-MM-dd", locale: AppLocale.currentLocale)"
    let visitDate: Date
    
    var insideMkad: Bool {
        distanceType == "inside_mkad"
    }
}

// sourcery: transformer
struct DoctorAppointmentInfoMessage {
    // sourcery: enumTransformer, enumTransformer.type = "String"
    enum MessageType: String {
        // sourcery: enumTransformer.value = "screen"
        case screen = "screen"
        // sourcery: enumTransformer.value = "alert"
        case alert = "alert"
    }
    // sourcery: transformer.name = "type"
    let type: MessageType
    // sourcery: transformer.name = "title"
    let title: String
    // sourcery: transformer.name = "text"
    let text: String
    // sourcery: transformer.name = "icon", transformer = "UrlTransformer<Any>()"
    let icon: URL?
    // sourcery: transformer.name = "actions"
    let actions: [DoctorAppointmentInfoMessageAction]
}

// sourcery: transformer
struct DoctorAppointmentInfoMessageAction {
    // sourcery: transformer.name = "title"
    let title: String
    
    // sourcery: enumTransformer, enumTransformer.type = "String"
    enum ActionType: String {
        // sourcery: enumTransformer.value = "close"
        // sourcery: defaultCase
        case close = "close"
        // sourcery: enumTransformer.value = "retry"
        case retry = "retry"
        // sourcery: enumTransformer.value = "chat"
        case chat = "chat"
    }
    
    // sourcery: transformer.name = "action"
    let type: ActionType
    
    // sourcery: transformer.name = "button_text_color"
    let textHexColor: String?
    
    // sourcery: transformer.name = "button_color"
    let backgroundHexColor: String?
}
