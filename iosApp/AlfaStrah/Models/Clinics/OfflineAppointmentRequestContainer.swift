//
//  OfflineAppointmentRequestContainer.swift
//  AlfaStrah
//
//  Created by Vitaly Shkinev on 02.09.2022.
//  Copyright © 2022 Touch Instinct. All rights reserved.
//

// sourcery: transformer
struct OfflineAppointmentRequestContainer {
    // sourcery: transformer.name = "appointment"
    let offlineAppointmentRequest: OfflineAppointmentRequest
    // sourcery: transformer.name = "cancel_appointment_avis_id"
    let cancelingAppointmentAvisId: Int?
}
