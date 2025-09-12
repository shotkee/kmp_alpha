//
//  DmsCostRecoveryAppliccationSubmitRequest.swift
//  AlfaStrah
//
//  Created by vit on 09.02.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

// sourcery: transformer
struct DmsCostRecoveryApplicationSubmitRequest {
    // sourcery: transformer.name = "request_id"
    var applicationId: String
    
    // sourcery: transformer.name = "file_id_list"
    var request: [String]
}
