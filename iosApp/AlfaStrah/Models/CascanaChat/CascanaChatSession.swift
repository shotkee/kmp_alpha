//
//  CascanaChatSession.swift
//  AlfaStrah
//
//  Created by vit on 20.06.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

import Foundation

// sourcery: transformer
class CascanaChatSession: NSObject {
    // sourcery: transformer.name = "cascana_token"
    var accessToken: String
    // sourcery: transformer.name = "refresh_token"
    var refreshToken: String?
    
    init(
        accessToken: String,
        refreshToken: String?
    ) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        super.init()
    }
}

// sourcery: transformer
struct CascanaChatTokenResponse {
    // sourcery: transformer.name = "accessToken"
    var accessToken: String
    // sourcery: transformer.name = "refreshToken"
    var refreshToken: String
}
