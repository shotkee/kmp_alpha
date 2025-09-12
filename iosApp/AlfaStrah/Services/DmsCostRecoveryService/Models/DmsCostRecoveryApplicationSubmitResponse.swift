//
//  DmsCostRecoveryApplicationSubmitResponse.swift
//  AlfaStrah
//
//  Created by vit on 09.02.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

// sourcery: transformer
struct DmsCostRecoveryApplicationSubmitResponse {
    // sourcery: transformer.name = "success"
    var isApplicationAccepted: Bool
    
    // sourcery: transformer.name = "title"
    var title: String
    
    // sourcery: transformer.name = "description"
    var description: String
}
