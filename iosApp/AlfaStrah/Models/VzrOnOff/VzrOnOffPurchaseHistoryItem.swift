//
//  VzrOnOffPurchaseHistoryItem.swift
//  AlfaStrah
//
//  Created by Amir Nuriev on 10/18/19.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

// sourcery: transformer
struct VzrOnOffPurchaseHistoryItem {
    // sourcery: transformer.name = "date_buy"
    // sourcery: transformer = "DateTransformer<Any>(format: "yyyy-MM-dd", locale: AppLocale.currentLocale)"
    var purchaseDate: Date
    var title: String
    var currency: String
    // Price in currency
    // sourcery: transformer.name = "currency_price"
    var currencyPrice: Double
    var days: Int

    var year: Int {
        AppLocale.calendar.component(.year, from: purchaseDate)
    }
}
