//
//  SosInsured.swift
//  AlfaStrah
//
//  Created by Makson on 28.11.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

import Foundation

// sourcery: transformer
struct SosInsured: Entity {
    // sourcery: transformer.name = "title"
    let title: String
    // sourcery: transformer.name = "full_name"
    let fullName: String
    // sourcery: transformer.name = "insurance_types"
    let insuranceTypes: [InsuranceType]
}

// sourcery: transformer
struct InsuranceType: Entity {
    // sourcery: transformer.name = "title_insurance_type"
    let title: String
    // sourcery: transformer.name = "call_phone"
    let phones: [Phone]
    // sourcery: transformer.name = "call_internet"
    let voipCalls: [VoipCall]
}
