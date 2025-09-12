//
//  RegisterAccountResponse.swift
//  AlfaStrah
//
//  Created by Амир Нуриев on 2/5/19.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

// sourcery: transformer
struct RegisterAccountResponse {
    // sourcery: transformer.name = "account"
    var account: Account
    // sourcery: transformer.name = "phone"
    var maskedPhoneNumber: String
    // sourcery: transformer.name = "code_time", transformer = NumberTransformer<Any, TimeInterval>()
    var otpVerificationResendTimeInterval: TimeInterval
}
