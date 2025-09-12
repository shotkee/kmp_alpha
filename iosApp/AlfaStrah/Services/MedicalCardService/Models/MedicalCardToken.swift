//
//  MedicalCardToken.swift
//  AlfaStrah
//
//  Created by Makson on 02.05.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

// sourcery: transformer
class MedicalCardToken: NSObject {
    // sourcery: transformer.name = "token"
    let token: String
    // sourcery: transformer.name = "datetime_expire"
    // sourcery: transformer = "DateTransformer<Any>()"
    let expirationDate: Date
    
    init(
        token: String,
        expirationDate: Date
    ) {
        self.token = token
        self.expirationDate = expirationDate
        super.init()
    }
}
