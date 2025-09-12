//
//  InsuranceActivateRequest.swift
//  AlfaStrah
//
//  Created by Amir Nuriev on 4/25/19.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

// sourcery: transformer
struct InsuranceActivateRequest {
    let price: Money
    let number: String
    // sourcery: transformer.name = "buy_date"
    // sourcery: transformer = "DateTransformer<Any>(format: "yyyy-MM-dd HH:mm:ss", locale: AppLocale.currentLocale)"
    let purchaseDate: Date
    // sourcery: transformer.name = "where_purchased"
    let purchaseLocation: String
    // sourcery: transformer.name = "ownership_type"
    let ownershipType: OwnershipType
    let insurer: InsuranceParticipant
}
