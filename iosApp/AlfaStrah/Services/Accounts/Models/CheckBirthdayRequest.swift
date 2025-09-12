//
//  CheckBirthdayRequest.swift
//  AlfaStrah
//
//  Created by Илья Матвеев on 21.06.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

// sourcery: transformer
struct CheckBirthdayRequest {
	// sourcery: transformer.name = "account_id", transformer = IdTransformer<Any>()
	var accountId: String
	// sourcery: transformer.name = "birthday", transformer = "DateTransformer<Any>(format: "yyyy-MM-dd", locale: AppLocale.currentLocale)"
	var birthDate: Date
	// sourcery: transformer.name = "email"
	var email: String
}
