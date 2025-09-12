//
//  ManageAppointmentRequest.swift
//  AlfaStrah
//
//  Created by Амир Нуриев on 1/28/19.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

// sourcery: transformer
struct ManageAppointmentRequest {
    // sourcery: transformer.name = "interval_id"
    let intervalId: String?
    // sourcery: transformer.name = "insurance_id"
    let insuranceId: String?
}
