//
//  OfflineAppointmentDate.swift
//  AlfaStrah
//
//  Created by Shukhrat Sagatov on 14.10.2021.
//  Copyright © 2021 Redmadrobot. All rights reserved.
//

// sourcery: transformer
struct OfflineAppointmentDate {
    // sourcery: transformer = "DateTransformer<Any>(format: "yyyy-MM-dd", locale: AppLocale.currentLocale)"
    let date: Date
    // sourcery: transformer.name = "start_time"
    let startTime: String
    // sourcery: transformer.name = "end_time"
    let endTime: String

    init(date: Date, startTime: String, endTime: String) {
        self.date = date
        self.startTime = startTime
        self.endTime = endTime
    }

    init?(date: Date, startHours: Int, endHours: Int) {
        let formatter: NumberFormatter = {
            let formatter = NumberFormatter()
            formatter.maximumIntegerDigits = 2
            formatter.minimumIntegerDigits = 2
            return formatter
        }()
        guard
            let startHH = formatter.string(from: NSNumber(value: startHours)),
            let endHH = formatter.string(from: NSNumber(value: endHours))
        else {
            return nil
        }
        self.date = date
        self.startTime = "\(startHH):00"
        self.endTime = "\(endHH):00"
    }
}
