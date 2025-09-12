//
//  FlatOnOffProtectionCalculation.swift
//  AlfaStrah
//
//  Created by Peter Tretyakov on 15.04.2020.
//  Copyright © 2020 Redmadrobot. All rights reserved.
//

// sourcery: transformer
struct FlatOnOffProtectionCalculation {
    // sourcery: transformer = IdTransformer<Any>()
    var id: String

    // sourcery: transformer.name = "start_date"
    // sourcery: transformer = "DateTransformer<Any>(format: "yyyy-MM-dd", locale: AppLocale.currentLocale)"
    var startDate: Date

    // sourcery: transformer.name = "end_date"
    // sourcery: transformer = "DateTransformer<Any>(format: "yyyy-MM-dd", locale: AppLocale.currentLocale)"
    var endDate: Date

    var days: Int

    // sourcery: transformer.name = "contract_url",
    // sourcery: transformer = "UrlTransformer<Any>()"
    var contractURL: URL

    // sourcery: transformer.name = "insurance_url"
    // sourcery: transformer = "UrlTransformer<Any>()"
    var insuranceURL: URL
}
