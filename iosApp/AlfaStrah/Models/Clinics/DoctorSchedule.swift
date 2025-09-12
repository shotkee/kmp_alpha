//
//  DoctorSchedule.swift
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 09/08/2018.
//  Copyright © 2018 RedMadRobot. All rights reserved.
//

// sourcery: transformer
struct DoctorSchedule {
    // sourcery: transformer = "DateTransformer<Any>(format: "yyyy-MM-dd", locale: AppLocale.currentLocale)"
    let date: Date
    // sourcery: transformer.name = "intervals"
    let scheduleIntervals: [DoctorScheduleInterval]
}

// sourcery: transformer
struct DoctorScheduleInterval {
    // sourcery: transformer = IdTransformer<Any>()
    let id: String
    // sourcery: transformer = "DateTransformer<Any>(format: "yyyy-MM-dd", locale: AppLocale.currentLocale)"
    let date: Date
    // sourcery: transformer.name = "start_time"
    let start: TimeInterval
    // sourcery: transformer.name = "end_time"
    let end: TimeInterval
    // sourcery: transformer.name = "is_free"
    let status: DoctorScheduleInterval.Status

    // sourcery: enumTransformer
    enum Status: Int {
        // sourcery: defaultCase
        case unavailable = 0
        case available = 1

        var isAvailable: Bool {
            self == .available
        }
    }

    var startDate: Date {
        var components = Calendar.current.dateComponents(in: TimeZone.current, from: date)
        components.hour = Int(start) / (60 * 60)
        components.minute = (Int(start) % (60 * 60)) / 60
        return components.date ?? date
    }

    var endDate: Date {
        var components = Calendar.current.dateComponents(in: TimeZone.current, from: date)
        components.hour = Int(end) / (60 * 60)
        components.minute = (Int(end) % (60 * 60)) / 60
        return components.date ?? date
    }
}
