//
//  RealmInsuranceBill.swift
//  AlfaStrah
//
//  Created by Vyacheslav Shakaev on 13.12.2021.
//  Copyright © 2021 Touch Instinct. All rights reserved.
//

import Foundation

class RealmInsuranceBill: RealmEntity {
    @objc dynamic var id: Int = 0
    @objc dynamic var recipientName: String = ""
    @objc dynamic var number: String = ""
    @objc dynamic var info: String = ""
    @objc dynamic var statusText: String = ""
    @objc dynamic var creationDate: Date = Date()
    @objc dynamic var moneyAmount: Double = 0
    @objc dynamic var billDescription: String = ""
    @objc dynamic var shouldBePaidOff: Bool = false
    @objc dynamic var canBePaidInGroup: Bool = false
    @objc dynamic var canSubmitDisagreement: Bool = false
    @objc dynamic var paymentDate: Date?
    @objc dynamic var highlighting: Int = 0
}
