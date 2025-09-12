//
//  StoryPage.swift
//  AlfaStrah
//
//  Created by Makson on 07.09.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

// sourcery: transformer
struct StoryPage: Entity {
    // sourcery: enumTransformer, enumTransformer.type = "String"
    enum BodyType: String {
        // sourcery: enumTransformer.value = "layout"
        case layout = "layout"
    }
    
    // sourcery: transformer.name = "page_id"
    let id: Int64
    // sourcery: transformer.name = "time"
    let time: Float
    // sourcery: transformer.name = "body_type"
    let bodyType: BodyType
    // sourcery: transformer.name = "body"
    let body: StoryPageBody?
    // sourcery: transformer.name = "cross_color"
    let crossColor: String
    // sourcery: transformer.name = "stripe_color"
    let stripeColor: String
    // sourcery: transformer.name = "button"
    let button: BackendButton?
}
