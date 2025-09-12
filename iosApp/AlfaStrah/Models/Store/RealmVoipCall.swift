//
//  RealmVoipCall.swift
//  AlfaStrah
//
//  Created by vit on 12.12.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

import RealmSwift

class RealmVoipCall: RealmEntity {
    @objc dynamic var title: String = ""
    @objc dynamic var internalType: String = ""
    @objc dynamic var parameters: Data?
}
