//
//  CascanaSearchResult.swift
//  AlfaStrah
//
//  Created by vit on 10.11.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

import Foundation

// sourcery: transformer
struct CascanaSearchResult {
    // sourcery: transformer.name = "id"
    let messageId: String
    
    // sourcery: transformer.name = "originalText"
    let text: String
    
    // sourcery: transformer.name = "highlightText"
    let highlightedText: String
    
    // sourcery: transformer.name = "registrationTime"
    // sourcery: transformer = "DateTransformer<Any>(format: "yyyy-MM-dd'T'HH:mm:ss.SSSZZZ", locale: AppLocale.currentLocale)"
    let date: Date
}

// sourcery: transformer
struct ChatSearchResponse {
    // sourcery: transformer.name = "isDisabled"
    let isDisabled: Bool
    
    // sourcery: transformer.name = "messages"
    let messages: [CascanaSearchResult]
}
