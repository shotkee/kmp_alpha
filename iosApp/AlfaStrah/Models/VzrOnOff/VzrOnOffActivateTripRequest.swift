//
//  VzrOnOffActivateTripRequest.swift
//  AlfaStrah
//
//  Created by Amir Nuriev on 11/1/19.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

// sourcery: transformer
struct VzrOnOffActivateTripRequest {
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
