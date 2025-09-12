//
//  VoxImplantCallData.swift
//  AlfaStrah
//
//  Created by vit on 12.12.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

import Foundation

// sourcery: transformer
struct VoxImplantCallData: Equatable {
    // sourcery: transformer.name = "username"
    let usernameForOneTimeLoginKey: String
    // sourcery: transformer.name = "from"
    let from: String
    // sourcery: transformer.name = "destination"
    let destination: String
    // sourcery: transformer.name = "headers"
    let headers: [VoxImplantCallHeader]
}

// sourcery: transformer
struct VoxImplantCallHeader: Equatable {
    // sourcery: transformer.name = "title"
    let title: String
    // sourcery: transformer.name = "value"
    let value: String
}
