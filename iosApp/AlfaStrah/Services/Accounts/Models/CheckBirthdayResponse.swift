//
//  CheckBirthdayResponse.swift
//  AlfaStrah
//
//  Created by Илья Матвеев on 21.06.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

// sourcery: transformer
struct CheckBirthdayResponse {
	// sourcery: transformer.name = "account_id", transformer = IdTransformer<Any>()
	var accountId: String
	// sourcery: transformer.name = "phone"
	var phone: Phone
	// sourcery: transformer.name = "email"
	var email: String
	// sourcery: transformer.name = "code_time_phone", transformer = NumberTransformer<Any, TimeInterval>()
	var smsCodeVerificationResendTimeInterval: TimeInterval
	// sourcery: transformer.name = "code_time_email", transformer = NumberTransformer<Any, TimeInterval>()
	var emailCodeVerificationResendTimeInterval: TimeInterval
}
