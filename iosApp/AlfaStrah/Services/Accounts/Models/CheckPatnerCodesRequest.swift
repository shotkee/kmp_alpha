//
//  CheckPatnerCodesRequest.swift
//  AlfaStrah
//
//  Created by Илья Матвеев on 21.06.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

// sourcery: transformer
struct CheckPatnerCodesRequest {
	// sourcery: transformer.name = "account_id", transformer = IdTransformer<Any>()
	var accountId: String
	// sourcery: transformer.name = "phone_code"
	var phoneCode: String
	// sourcery: transformer.name = "email_code"
	var emailCode: String
}
