//
//  InsuranceCalculation.swift
//  AlfaStrah
//
//  Created by Evgeny Ivanov on 22/01/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

// sourcery: transformer
struct InsuranceCalculation {
    var price: Double

    // sourcery: transformer.name = "max_spend_points"
    var maxSpendPoints: Int

    // sourcery: transformer.name = "accrual_points"
    var accrualPoints: Int

    // sourcery: transformer.name = "date_start"
    // sourcery: transformer = "DateTransformer<Any>(format: "yyyy-MM-dd HH:mm:ss", locale: AppLocale.currentLocale)"
    var startDate: Date?

    // sourcery: transformer.name = "date_end"
    // sourcery: transformer = "DateTransformer<Any>(format: "yyyy-MM-dd HH:mm:ss", locale: AppLocale.currentLocale)"
    var endDate: Date?
}

// sourcery: transformer
struct InsurancePonts {
    var points: Int
}

// sourcery: transformer
struct InsuranceId {
    // sourcery: transformer = IdTransformer<Any>()
    var id: String
}
