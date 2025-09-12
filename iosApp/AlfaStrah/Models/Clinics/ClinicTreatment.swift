//
//  ClinicTreatment.swift
//  AlfaStrah
//
//  Created by Vasyl Kotsiuba on 17.08.2018.
//  Copyright © 2018 RedMadRobot. All rights reserved.
//

// sourcery: transformer
struct ClinicTreatment {
    // sourcery: transformer = IdTransformer<Any>()
    let id: String
    let title: String
    // sourcery: transformer.name = "has_franchise"
    let hasFranchise: Bool
    // sourcery: transformer.name = "franchise_size"
    let franchisePercentage: String?
}
