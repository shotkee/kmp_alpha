//
//  HealthAcademyCard.swift
//  AlfaStrah
//
//  Created by mac on 26.08.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

import Foundation

struct HealthAcademyCard {
    enum CardType {
        case url(URL?)
        case group(HealthAcademyCardGroup?)
    }
    
    var cardId: Int
    var title: String
    var imageURL: URL
	var imageThemedURL: ThemedValue?
    var type: CardType
}
