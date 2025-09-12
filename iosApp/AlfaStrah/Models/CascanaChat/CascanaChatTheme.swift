//
//  CascanaChatTheme.swift
//  AlfaStrah
//
//  Created by vit on 21.06.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

import Foundation

// sourcery: transformer
struct CascanaChatTheme {
    // sourcery: transformer.name = "id"
    var id: String
    // sourcery: transformer.name = "name"
    var name: String
    // sourcery: transformer.name = "children"
    var children: [CascanaChatChildTheme]
}

// sourcery: transformer
struct CascanaChatChildTheme {
    // sourcery: transformer.name = "id"
    var id: String
    // sourcery: transformer.name = "name"
    var name: String
    // sourcery: transformer.name = "children"
    var children: [String]
}
