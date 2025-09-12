//
//  RealmAnonymousSos.swift
//  AlfaStrah
//
//  Created by Makson on 30.11.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

import RealmSwift

class RealmAnonymousSos: RealmEntity {
    let sosList: List<RealmSosModel> = .init()
    @objc dynamic var sosEmergencyCommunication: RealmSosEmergencyCommunication?
}
