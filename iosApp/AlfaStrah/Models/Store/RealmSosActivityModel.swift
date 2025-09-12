//
//  RealmSosActivityModel.swift
//  AlfaStrah
//
//  Created by Evgeny Ivanov on 12/04/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import RealmSwift

class RealmSosActivityModel: RealmEntity {
    @objc dynamic var id: Int = 0
    @objc dynamic var title: String = ""
    @objc dynamic var modelDescription: String = ""
    let insuranceIdList: List<String> = .init()
    let sosPhoneList: List<RealmSosPhone> = .init()
}

class RealmSosPhone: RealmEntity {
    @objc dynamic var title: String = ""
    @objc dynamic var modelDecription: String = ""
    @objc dynamic var phone: String = ""
    @objc dynamic var voipCall: RealmVoipCall?
}
