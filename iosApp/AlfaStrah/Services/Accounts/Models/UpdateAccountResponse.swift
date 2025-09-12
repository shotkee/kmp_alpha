//
//  UpdateAccountResponse.swift
//  AlfaStrah
//
//  Created by vit on 06.09.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

// sourcery: transformer
struct UpdateAccountResponse {
    // sourcery: transformer.name = "account"
    var account: Account
    // sourcery: transformer.name = "code_time", transformer = NumberTransformer<Any, TimeInterval>()
    var otpVerificationResendTimeInterval: TimeInterval
}
