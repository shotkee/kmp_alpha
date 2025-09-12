//
//  ResetPasswordRequest.swift
//  AlfaStrah
//
//  Created by Амир Нуриев on 2/6/19.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

// sourcery: transformer
struct ResetPasswordRequest {
    var email: String
    // sourcery: transformer.name = "phone_number"
    var phoneNumber: String
}
