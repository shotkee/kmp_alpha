//
//  CheckInsuranceExtendedDataRequirement.swift
//  AlfaStrah
//
//  Created by Амир Нуриев on 2/5/19.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

// sourcery: transformer
struct CheckExtendedDataRequest {
    // sourcery: transformer.name = "insurance_number"
    var insuranceNumber: String
    // sourcery: transformer.name = "first_name"
    var firstName: String
    // sourcery: transformer.name = "last_name"
    var lastName: String
    // sourcery: transformer.name = "phone_number"
    var phone: String
    // sourcery: transformer.name = "birth_date", transformer = TimestampTransformer<Any>(scale: 1)
    var birthDate: Date
}
