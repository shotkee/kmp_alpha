//
//  DmsCostRecoveryApplicationResponse.swift
//  AlfaStrah
//
//  Created by vit on 07.02.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

// sourcery: transformer
struct DmsCostRecoveryApplicationResponse {
    // sourcery: transformer.name = "request_id"
    let applicationId: String
    // sourcery: transformer.name = "acceptance"
    let details: LinkedText
}
