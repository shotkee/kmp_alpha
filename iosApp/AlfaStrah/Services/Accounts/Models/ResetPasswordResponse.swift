//
//  ResetPasswordResponse.swift
//  AlfaStrah
//
//  Created by Амир Нуриев on 2/6/19.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

// sourcery: transformer
struct ResetPasswordResponse {
	// sourcery: enumTransformer, enumTransformer.type = "String"
	enum PassRecoveryFlow {
		// sourcery: enumTransformer.value = "default"
		case regular
		// sourcery: enumTransformer.value = "partner"
		case partner
	}
	// sourcery: transformer.name = "account_id", transformer = IdTransformer<Any>()
    var accountId: String
    // sourcery: transformer.name = "phone"
    var phone: Phone
    // sourcery: transformer.name = "code_time", transformer = NumberTransformer<Any, TimeInterval>()
    var otpVerificationResendTimeInterval: TimeInterval
	// sourcery: transformer.name = "flow"
	var passRecoveryFlow: PassRecoveryFlow
}
