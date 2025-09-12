//
//  RealmLoyaltyModel.swift
//  AlfaStrah
//
//  Created by Evgeny Ivanov on 27/04/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import Foundation
import RealmSwift

class RealmLoyaltyModel: RealmEntity {
    @objc dynamic var amount: Double = 0.0
    @objc dynamic var added: Double = 0.0
    @objc dynamic var status: String = ""
    @objc dynamic var spent: Double = 0.0
    @objc dynamic var statusDescription: String = ""
    @objc dynamic var nextStatus: String?
    @objc dynamic var nextStatusDescription: String = ""
    @objc dynamic var nextStatusMoney: Double = 0.0
    @objc dynamic var hotlineDescription: String?
    @objc dynamic var operationsCnt: Int = 0
    @objc dynamic var hotlinePhone: RealmPhone?
    let lastOperations: List<RealmLoyaltyOperation> = .init()
    let insuranceDeeplinkTypes: List<RealmInsuranceDeeplinkType> = .init()
}

class RealmInsuranceDeeplinkType: RealmEntity {
    @objc dynamic var id: String = ""
    @objc dynamic var title: String = ""
    @objc dynamic var categoryId: String = ""
}

class RealmLoyaltyOperation: RealmEntity {
    @objc dynamic var id: String = ""
    @objc dynamic var productId: String?
    @objc dynamic var categoryId: String?

    @objc dynamic var amount: Double = 0.0
    @objc dynamic var date: Date = Date()
    @objc dynamic var modelDescription: String = ""
    @objc dynamic var statusDescription: String?
    @objc dynamic var contractNumber: String?

    dynamic var operationType: RealmProperty<Int?> = .init()
    dynamic var categoryType: RealmProperty<Int?> = .init()
    dynamic var status: RealmProperty<Int?> = .init()
    dynamic var insuranceDeeplinkTypeId: RealmProperty<Int?> = .init()
    dynamic var iconType: RealmProperty<Int?> = .init()
    dynamic var loyaltyType: RealmProperty<Int?> = .init()
}
