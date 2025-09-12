//
//  InsuranceDeeplinkType.swift
//  AlfaStrah
//
//  Created by Eugene Ivanov on 28/03/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

// sourcery: transformer
struct InsuranceDeeplinkType: Entity {
    // sourcery: transformer = IdTransformer<Any>()
    var id: String

    var title: String

    // sourcery: transformer.name = "category_id", transformer = IdTransformer<Any>()
    var categoryId: String
}
