//
//  OsagoProlongationCalculateInfo.swift
//  AlfaStrah
//
//  Created by Nikita Omelchenko on 18.02.2021.
//  Copyright © 2021 Redmadrobot. All rights reserved.
//

// sourcery: transformer
struct OsagoProlongationCalculateInfo {
    var sum: Double

    // sourcery: transformer.name = "start_date"
    // sourcery: transformer = "DateTransformer<Any>(format: "yyyy-MM-dd", locale: AppLocale.currentLocale)"
    var startDate: Date

    // sourcery: transformer.name = "end_date"
    // sourcery: transformer = "DateTransformer<Any>(format: "yyyy-MM-dd", locale: AppLocale.currentLocale)"
    var endDate: Date

    // sourcery: transformer.name = "car_mark"
    var carMark: String?

    // sourcery: transformer.name = "car_regnum"
    var carRegistrationNumber: String?

    // sourcery: transformer.name = "car_vin"
    var carVin: String?
}
