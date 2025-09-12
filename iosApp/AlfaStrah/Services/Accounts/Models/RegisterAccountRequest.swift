//
//  RegisterAccountRequest.swift
//  AlfaStrah
//
//  Created by Амир Нуриев on 2/11/19.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

// sourcery: transformer
struct RegisterAccountRequest {
    // sourcery: transformer.name = "first_name"
    var firstName: String
    // sourcery: transformer.name = "last_name"
    var lastName: String
    // sourcery: transformer.name = "phone_number"
    var phoneNumber: String
    // sourcery: transformer.name = "birth_date_iso", transformer = "DateTransformer<Any>(format: "yyyy-MM-dd", locale: AppLocale.currentLocale)"
    var birthDateISO: Date
    // sourcery: transformer.name = "insurance_number"
    var insuranceNumber: String?
    var email: String
    var patronymic: String?
    var type: AccountType
    // sourcery: transformer.name = "device_token"
    var deviceToken: String
    var seed: String
    var hash: String
    // sourcery: transformer.name = "agreed"
    var agreedToPersonalDataPolicy: Bool
}
