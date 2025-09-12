//
//  ResendPartnerEmailCodeResponse.swift
//  AlfaStrah
//
//  Created by Илья Матвеев on 21.06.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

// sourcery: transformer
struct ResendPartnerEmailCodeResponse {
	// sourcery: transformer.name = "email"
	var email: String
	// sourcery: transformer.name = "code_time", transformer = NumberTransformer<Any, TimeInterval>()
	var emailCodePartnerResendTimeInterval: TimeInterval
}
