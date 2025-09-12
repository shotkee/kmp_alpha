//
//  FlatOnOffProtection.swift
//  AlfaStrah
//
//  Created by Peter Tretyakov on 31.03.2020.
//  Copyright © 2020 Redmadrobot. All rights reserved.
//

// sourcery: transformer
struct FlatOnOffProtection: Entity {
    // sourcery: enumTransformer
    enum Status: Int {
        // sourcery: defaultCase
        case planned = 1
        case active = 2
        case expired = 3
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

    var status: FlatOnOffProtection.Status
}
