//
//  OfflineAppointmentSettings.swift
//  AlfaStrah
//
//  Created by Shukhrat Sagatov on 13.10.2021.
//  Copyright © 2021 Redmadrobot. All rights reserved.
//

// sourcery: transformer
struct OfflineAppointmentSettings {
    // sourcery: transformer.name = "clinic_specialities"
    let clinicSpecialities: [ClinicSpeciality]
    // sourcery: transformer.name = "min_date_days"
    let minDateDays: Int
    // sourcery: transformer.name = "max_date_days"
    let maxDateDays: Int
    // sourcery: transformer.name = "min_interval"
    let minInterval: Int
    // sourcery: transformer.name = "interval_start_time"
    let intervalStartTime: String
    // sourcery: transformer.name = "interval_end_time"
    let intervalEndTime: String
    let disclaimer: String?
}
