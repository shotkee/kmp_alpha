//
//  ResendSmsResponse.swift
//  AlfaStrah
//
//  Created by vit on 06.09.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

// sourcery: transformer
struct ResendSmsResponse {
    // sourcery: transformer.name = "phone"
    var phone: Phone
    // sourcery: transformer.name = "code_time", transformer = NumberTransformer<Any, TimeInterval>()
    var otpVerificationResendTimeInterval: TimeInterval
}
