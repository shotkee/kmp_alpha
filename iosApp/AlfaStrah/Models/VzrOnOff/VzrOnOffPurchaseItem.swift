//
//  VzrOnOffPurchaseItem.swift
//  AlfaStrah
//
//  Created by Amir Nuriev on 10/16/19.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

// sourcery: transformer
struct VzrOnOffPurchaseItem {
    // sourcery: transformer = IdTransformer<Any>()
    var id: String
    var title: String
    var currency: String
    // sourcery: transformer.name = "currency_price"
    var currencyPrice: Double
    var days: Int
    // sourcery: transformer.name = "oferta_url"
    var ofertaUrl: String
    // sourcery: transformer.name = "success_text"
    var successText: String
}
