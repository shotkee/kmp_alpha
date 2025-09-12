//
//  InsuranceGroupCategory.swift
//  AlfaStrah
//
//  Created by Evgeny Ivanov on 31/03/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

// sourcery: transformer
struct InsuranceGroupCategory: Entity {
    // sourcery: transformer.name = "insurance_category"
    var insuranceCategory: InsuranceCategoryMain
    // sourcery: transformer.name = "insurance_list"
    var insuranceList: [InsuranceShort]
    // sourcery: transformer.name = "sos_activity"
    var sosActivity: SosActivityModel?

    var renewInsuranceCount: Int {
        insuranceList.compactMap { $0 }.filter { $0.renewAvailable }.count
    }

    var isSupported: Bool {
        let insurances = insuranceList.compactMap { $0 }
        let unsupported = insurances.allSatisfy { $0.type == .unsupported }
        return !unsupported
    }
}
