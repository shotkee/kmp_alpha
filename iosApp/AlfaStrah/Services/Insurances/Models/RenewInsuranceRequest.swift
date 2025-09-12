//
//  RenewInsuranceRequest.swift
//  AlfaStrah
//
//  Created by Vyacheslav Shakaev on 11.11.2021.
//  Copyright © 2021 Touch Instinct. All rights reserved.
//

// sourcery: transformer
struct RenewInsuranceRequest {
    // sourcery: transformer.name = "points"
    var insurancePonts: Int
    // sourcery: transformer.name = "agreed"
    var agreedToPersonalDataPolicy: Bool
}
