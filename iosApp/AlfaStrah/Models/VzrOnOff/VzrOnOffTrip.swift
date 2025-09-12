//
//  TravelOnOffTrip.swift
//  AlfaStrah
//
//  Created by Amir Nuriev on 10/8/19.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

// sourcery: transformer
struct VzrOnOffTrip: Entity {
    // sourcery: enumTransformer
    enum TripStatus: Int {
        // sourcery: defaultCase
        case planned = 1
        case active = 2
        case passed = 3
    }

    // sourcery: transformer = IdTransformer<Any>()
    var id: String

    // sourcery: transformer.name = "start_date"
    // sourcery: transformer = "DateTransformer<Any>(format: "yyyy-MM-dd", locale: AppLocale.currentLocale)"
    var startDate: Date

    // sourcery: transformer.name = "end_date"
    // sourcery: transformer = "DateTransformer<Any>(format: "yyyy-MM-dd", locale: AppLocale.currentLocale)"
    var endDate: Date

    var days: Int

    var status: VzrOnOffTrip.TripStatus

    var years: [Int] {
        [
            AppLocale.calendar.dateComponents([ .year ], from: startDate).year,
            AppLocale.calendar.dateComponents([ .year ], from: endDate).year
        ].compactMap { $0 }
    }
}
