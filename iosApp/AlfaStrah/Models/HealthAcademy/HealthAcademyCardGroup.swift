//
//  HealthAcademyCardGroup.swift
//  AlfaStrah
//
//  Created by mac on 26.08.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

import Foundation

struct HealthAcademyCardGroup {
    enum Kind: String {
        case tile = "block"
        case list = "list"
    }
    
    var cardGroupId: Int
    var cards: [HealthAcademyCard]
    var title: String
    var type: Kind
}
