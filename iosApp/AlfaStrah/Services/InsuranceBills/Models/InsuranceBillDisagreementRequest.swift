//
//  InsuranceBillDisagreementRequest.swift
//  AlfaStrah
//
//  Created by Vitaly Trofimov on 19.06.2022.
//  Copyright © 2022 Touch Instinct. All rights reserved.
//

import Foundation

// sourcery: transformer
struct InsuranceBillDisagreementRequest
{
    // sourcery: transformer.name = "insurance_id"
    let insuranceId: String
    
    // sourcery: transformer.name = "bill_id"
    let insuranceBillId: Int
    
    // sourcery: transformer.name = "reason_id"
    let reasonId: Int
    
    // sourcery: transformer.name = "service_ids"
    let servicesIds: [Int]
    
    let comment: String
    
    let phone: String?
    
    let email: String?
    
    // sourcery: transformer.name = "file_ids"
    let documentsIds: [Int]
}
