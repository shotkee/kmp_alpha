//
//  InsuranceBillPaymentURLRequest.swift
//  AlfaStrah
//
//  Created by Vitaly Trofimov on 22.12.2021.
//  Copyright © 2021 Touch Instinct. All rights reserved.
//

// sourcery: transformer
struct InsuranceBillPaymentURLRequest {
    // sourcery: transformer.name = "insurance_id"
    let insuranceId: String

    // sourcery: transformer.name = "bill_ids"
    let billIds: [Int]

    // sourcery: transformer.name = "email"
    let email: String
    
    // sourcery: transformer.name = "phone"
    let phone: String
}
