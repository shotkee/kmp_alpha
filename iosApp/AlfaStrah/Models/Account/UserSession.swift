//
//  AccountSession.swift
//  AlfaStrah
//
//  Created by Eugene Ivanov on 31/01/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

// sourcery: transformer
class UserSession: NSObject {
    // sourcery: transformer = IdTransformer<Any>()
    var id: String
    // sourcery: transformer.name = "access_token"
    var accessToken: String

    init(id: String, accessToken: String) {
        self.id = id
        self.accessToken = accessToken
        super.init()
    }
}
