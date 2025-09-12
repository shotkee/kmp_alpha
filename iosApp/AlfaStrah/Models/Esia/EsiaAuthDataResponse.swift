//
//  EsiaAuthDataResponse.swift
//  AlfaStrah
//
//  Created by vit on 06.12.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

import Foundation

// sourcery: transformer
struct EsiaAuthDataResponse {
    // sourcery: transformer.name = "redirect_url", transformer = "UrlTransformer<Any>()"
    let redirectUrl: URL
    // sourcery: transformer.name = "regexp"
    let regexp: String
    // sourcery: transformer.name = "token_cookie_name"
    let esiaTokenCookieFieldName: String
}
