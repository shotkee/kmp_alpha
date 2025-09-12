//
//  RealmInsuranceMain.swift
//  AlfaStrah
//
//  Created by Evgeny Ivanov on 12/04/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import RealmSwift

class RealmInsuranceMain: RealmEntity {
    let insuranceGroupList: List<RealmInsuranceGroup> = .init()
    let sosList: List<RealmSosModel> = .init()
    @objc dynamic var sosEmergencyCommunication: RealmSosEmergencyCommunication?
}
