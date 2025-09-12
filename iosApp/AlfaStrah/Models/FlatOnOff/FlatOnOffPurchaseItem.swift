//
//  FlatOnOffPurchaseItem.swift
//  AlfaStrah
//
//  Created by Амир Нуриев on 12.04.2020.
//  Copyright © 2020 Redmadrobot. All rights reserved.
//

// sourcery: transformer
struct FlatOnOffPurchaseItem {
    // sourcery: transformer = IdTransformer<Any>()
    var id: String
    var title: String
    var price: Double
    var days: Int
    // sourcery: transformer.name = "success_text"
    var successText: String
    // sourcery: transformer.name = "contract_url"
    // sourcery: transformer = "UrlTransformer<Any>()"
    var contractUrl: URL
    // sourcery: transformer.name = "insurance_url"
    // sourcery: transformer = "UrlTransformer<Any>()"
    var insuranceUrl: URL
}
