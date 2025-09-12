//
//  OsagoProlongationDeeplinkRequest.swift
//  AlfaStrah
//
//  Created by Vyacheslav Shakaev on 11.11.2021.
//  Copyright © 2021 Touch Instinct. All rights reserved.
//

// sourcery: transformer
struct OsagoProlongationDeeplinkRequest {
    // sourcery: transformer.name = "insurance_id"
    var insuranceId: String
    // sourcery: transformer.name = "agreed"
    var agreedToPersonalDataPolicy: Bool
}
