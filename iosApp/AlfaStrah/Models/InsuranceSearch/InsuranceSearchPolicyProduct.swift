//
//  SearchProduct.swift
//  AlfaStrah
//
//  Created by Evgeny Ivanov on 11/01/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

// sourcery: transformer
struct InsuranceSearchPolicyProduct: Equatable {
    // sourcery: transformer = IdTransformer<Any>()
    var id: String
    var title: String

    var suggest: String?
    var example: String?

    var isDms: Bool {
        title == "ДМС"
    }

    var isOsago: Bool {
        title == "ОСАГО"
    }

    var isAccident: Bool {
        title == "НС"
    }
}
