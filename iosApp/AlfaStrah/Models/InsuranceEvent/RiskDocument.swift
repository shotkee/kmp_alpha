//
//  RiskDocument.swift
//  AlfaStrah
//
//  Created by Eugene Ivanov on 30/05/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

// sourcery: transformer
struct RiskDocument {
    var id: Int
    var title: String
    var description: String
    // sourcery: transformer.name = "is_required"
    var isRequired: Int
    var required: Bool {
        isRequired == 1
    }
}
