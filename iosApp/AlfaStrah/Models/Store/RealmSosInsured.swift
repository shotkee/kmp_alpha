//
//  RealmSosInsured.swift
//  AlfaStrah
//
//  Created by Makson on 28.11.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//
import RealmSwift

class RealmSosInsured: RealmEntity {
    @objc dynamic var title: String = ""
    @objc dynamic var fullName: String = ""
    let insuranceTypes: List<RealmInsuranceType> = .init()
}

class RealmInsuranceType: RealmEntity {
    @objc dynamic var title: String = ""
    let phones: List<RealmPhone> = .init()
    let voipCalls: List<RealmVoipCall> = .init()
}
