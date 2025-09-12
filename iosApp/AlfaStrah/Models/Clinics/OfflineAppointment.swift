//
//  OfflineAppointment.swift
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 23/08/2018.
//  Copyright © 2018 RedMadRobot. All rights reserved.
//

// sourcery: transformer
struct OfflineAppointment {
    // sourcery: transformer = IdTransformer<Any>()
    let id: String
    // sourcery: transformer.name = "avis_id"
    let appointmentNumber: String
    let phone: Phone
    // sourcery: transformer = "TimestampTransformer<Any>(scale: 1)"
    var date: Date
    // sourcery: transformer.name = "reason_text"
    var reason: String
    // sourcery: transformer.name = "clinic_id"
    let clinicId: String
    var clinic: Clinic?
    // sourcery: transformer.name = "insurance_id"
    let insuranceId: String
}
