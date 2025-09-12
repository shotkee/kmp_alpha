//
//  AuthSmsCode.swift
//  AlfaStrah
//
//  Created by Makson on 03.10.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

import Foundation

// sourcery: transformer
struct AuthSmsCode: Equatable
{
	// sourcery: transformer.name = "phone"
	var phone: Phone
	
	// sourcery: transformer.name = "code_length"
	var codeLength: String
	
	// sourcery: transformer.name = "code_time"
	var codeTime: Int
}
