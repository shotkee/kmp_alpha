//
//  InsuranceGroup.swift
//  AlfaStrah
//
//  Created by Evgeny Ivanov on 31/03/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

// sourcery: transformer
struct InsuranceGroup: Entity {
    // sourcery: transformer.name = "object_name"
    var objectName: String
    // sourcery: transformer.name = "object_type"
    var objectType: String
    // sourcery: transformer.name = "insurance_group_category_list"
    var insuranceGroupCategoryList: [InsuranceGroupCategory]

    var renewInsuranceCount: Int {
        insuranceGroupCategoryList.compactMap { $0 }.reduce(0) { $0 + $1.renewInsuranceCount }
    }

    var isSupported: Bool {
        let unsupported = insuranceGroupCategoryList.compactMap { $0.isSupported }.allSatisfy { $0 == false }
        return !unsupported
    }
}
