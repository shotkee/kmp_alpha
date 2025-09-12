//
//  FlatOnOffInsurance.swift
//  AlfaStrah
//
//  Created by Peter Tretyakov on 31.03.2020.
//  Copyright © 2020 Redmadrobot. All rights reserved.
//

// sourcery: transformer
struct FlatOnOffInsurance: Entity {
    // sourcery: transformer.name = "insurance_id"
    // sourcery: transformer = IdTransformer<Any>()
    var id: String
    // sourcery: transformer.name = "active_protection_list"
    var protections: [FlatOnOffProtection]
}
