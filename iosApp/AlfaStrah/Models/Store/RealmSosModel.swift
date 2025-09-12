//
//  RealmSosModel.swift
//  AlfaStrah
//
//  Created by Evgeny Ivanov on 12/04/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import RealmSwift

class RealmSosModel: RealmEntity {
    @objc dynamic var insuranceCategory: RealmInsuranceCategoryMain?
    @objc dynamic var sosPhone: RealmPhone?
    @objc dynamic var kind: Int = 1
    @objc dynamic var isHealthFlow: Bool = false
    @objc dynamic var isActive: Bool = false
    @objc dynamic var insuranceCount: Int = 0
    let instructionList: List<RealmInstruction> = .init()
    let sosActivityList: List<RealmSosActivityModel> = .init()
}
