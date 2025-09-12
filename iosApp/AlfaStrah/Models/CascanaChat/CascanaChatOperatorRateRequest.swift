//
//  CascanaChatOperatorRateRequest.swift
//  AlfaStrah
//
//  Created by vit on 07.07.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

import Foundation

// sourcery: transformer
struct CascanaChatOperatorRateRequest {
    // sourcery: transformer.name = "RequestId"
    let requestId: String
    // sourcery: transformer.name = "Score"
    let rate: Int
    // sourcery: transformer.name = "Comment"
    let comment: String?
    // sourcery: transformer.name = "OperatorId"
    let senderId: String?
}
