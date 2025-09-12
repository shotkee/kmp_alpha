//
//  PurchaseLinkRequest.swift
//  AlfaStrah
//
//  Created by Amir Nuriev on 11/6/19.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

// sourcery: transformer
struct PurchaseLinkRequest {
    // sourcery: transformer.name = "insurance_id"
    // sourcery: transformer = IdTransformer<Any>()
    let insuranceId: String
    // sourcery: transformer.name = "purchaseitem_id"
    // sourcery: transformer = IdTransformer<Any>()
    let purchaseItemId: String
}
