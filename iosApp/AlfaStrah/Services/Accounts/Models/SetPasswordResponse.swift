//
//  SetPasswordResponse.swift
//  AlfaStrah
//
//  Created by Амир Нуриев on 2/6/19.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

// sourcery: transformer
struct SetPasswordResponse {
    var success: Bool
    var account: Account
    var message: String
}
