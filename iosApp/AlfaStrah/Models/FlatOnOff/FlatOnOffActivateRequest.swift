//
//  FlatOnOffActivateRequest.swift
//  AlfaStrah
//
//  Created by Peter Tretyakov on 15.04.2020.
//  Copyright © 2020 Redmadrobot. All rights reserved.
//

// sourcery: transformer
struct FlatOnOffActivateRequest {
    // sourcery: transformer.name = "insurance_id"
    // sourcery: transformer = IdTransformer<Any>()
    let insuranceId: String
    // sourcery: transformer.name = "start_date"
    // sourcery: transformer = "DateTransformer<Any>(format: "yyyy-MM-dd", locale: AppLocale.currentLocale)"
    let startDate: Date
    // sourcery: transformer.name = "end_date"
    // sourcery: transformer = "DateTransformer<Any>(format: "yyyy-MM-dd", locale: AppLocale.currentLocale)"
    let endDate: Date
}
