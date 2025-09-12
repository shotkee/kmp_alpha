//
//  SetPasswordRequest.swift
//  AlfaStrah
//
//  Created by Амир Нуриев on 2/6/19.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

// sourcery: transformer
struct SetPasswordRequest {
    // sourcery: transformer.name = "old_password"
    var oldPassword: String
    var password: String
}
