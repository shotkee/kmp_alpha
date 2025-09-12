//
//  LinkedText.swift
//  AlfaStrah
//
//  Created by vit on 04.09.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

// sourcery: transformer
struct LinkedText {
    // sourcery: transformer.name = "text"
    let text: String
    // sourcery: transformer.name = "links"
    let links: [Link]
}

// sourcery: transformer
struct Link {
    // sourcery: transformer.name = "text"
    let text: String
    // sourcery: transformer.name = "link"
    let path: String
}
