//
//  OfflineAppointmentRequest.swift
//  AlfaStrah
//
//  Created by Shukhrat Sagatov on 14.10.2021.
//  Copyright © 2021 Redmadrobot. All rights reserved.
//

// sourcery: transformer
struct OfflineAppointmentRequest {
    let phone: Phone
    // sourcery: transformer.name = "reason_text"
    var reason: String
    // sourcery: transformer.name = "clinic_id"
    let clinicId: String
    // sourcery: transformer.name = "insurance_id"
    let insuranceId: String

    let dates: [OfflineAppointmentDate]
    // sourcery: transformer.name = "clinic_speciality_id"
    let clinicSpecialityId: Int
    // sourcery: transformer.name = "user_input"
    let userInputForClinicSpeciality: String?
    // sourcery: transformer.name = "disclaimer_answer"
    let disclaimerAnswer: String?
}
