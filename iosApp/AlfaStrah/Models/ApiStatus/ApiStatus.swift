//
//  ApiStatus.swift
//  AlfaStrah
//
//  Created by Vitaly Shkinev on 21.11.2022.
//  Copyright © 2022 Touch Instinct. All rights reserved.
//

// sourcery: transformer
struct ApiStatus {
    // sourcery: enumTransformer, enumTransformer.type = "String"
    enum State {
        // sourcery: enumTransformer.value = "normal", defaultCase
        case normal
        // sourcery: enumTransformer.value = "restricted"
        case restricted
        // sourcery: enumTransformer.value = "blocked"
        case blocked
    }
    
    // sourcery: transformer.name = "status"
    let state: ApiStatus.State
    
    // sourcery: transformer.name = "title"
    let title: String
    
    // sourcery: transformer.name = "description"
    let description: String
}
