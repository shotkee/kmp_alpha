//
//  InfoField.swift
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 05/12/2018.
//  Copyright © 2018 Redmadrobot. All rights reserved.
//

// sourcery: transformer
struct InfoField: Entity {
    // sourcery: enumTransformer
    enum Kind: Int {
        // sourcery: defaultCase
        case text = 1
        case map = 2
        case link = 3
        case phone = 4
        case clinicsList = 5
    }

    var type: InfoField.Kind
    var title: String
    var text: String
    var coordinate: Coordinate?
}
