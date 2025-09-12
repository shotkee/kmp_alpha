//
//  LoyaltyBlock.swift
//  AlfaStrah
//
//  Created by Elizaveta Prokudina on 28.09.2021.
//  Copyright © 2021 Redmadrobot. All rights reserved.
//

// sourcery: transformer
struct LoyaltyBlock: Entity {
    var id: Int
    var title: String

    var description: String
    // sourcery: transformer.name = "image_url"
    var imageUrl: String
}
