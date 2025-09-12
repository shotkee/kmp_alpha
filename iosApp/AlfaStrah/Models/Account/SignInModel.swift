//
//  SignInModel.swift
//  AlfaStrah
//
//  Created by Eugene Ivanov on 06/02/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

// sourcery: transformer
struct SignInModel {
    var login: String
    var password: String
    var type: AccountType
    // sourcery: transformer.name = "is_demo"
    var isDemo: SessionType
    // sourcery: transformer.name = "device_token"
    var deviceToken: String
    var seed: String
    var hash: String
}
