//
//  PropertyRenewCalcResponse.swift
//  AlfaStrah
//
//  Created by Amir Nuriev on 6/13/19.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

// sourcery: transformer
struct PropertyRenewCalcResponse {
    var price: Int

    // sourcery: transformer.name = "start_date"
    // sourcery: transformer = "DateTransformer<Any>(format: "yyyy-MM-dd HH:mm:ss", locale: AppLocale.currentLocale)"
    var startDate: Date

    // sourcery: transformer.name = "end_date"
    // sourcery: transformer = "DateTransformer<Any>(format: "yyyy-MM-dd HH:mm:ss", locale: AppLocale.currentLocale)"
    var endDate: Date

    // sourcery: transformer.name = "accrual_points"
    var accrualPoints: Int

    // sourcery: transformer.name = "max_spend_points"
    var maxSpendPoints: Int

    var risks: [InsuranceProlongationEstateRisk]
}
