//
// RealmAppNotification
// AlfaStrah
//
// Created by Eugene Egorov on 04 February 2019.
// Copyright (c) 2019 Redmadrobot. All rights reserved.
//

import Foundation
import RealmSwift

class RealmAppNotification: RealmEntity {
    @objc dynamic var id: String = ""
    @objc dynamic var type: Int = 0
    @objc dynamic var title: String = ""
    @objc dynamic var annotation: String = ""
    @objc dynamic var fullText: String = ""
    @objc dynamic var date: Date = Date()
    @objc dynamic var important: Bool = false
    @objc dynamic var insuranceId: String = ""
    @objc dynamic var stoa: RealmStoa?
    @objc dynamic var offlineAppointmentId: String?
    let fieldList: List<RealmAppNotificationField> = .init()
    @objc dynamic var phone: RealmPhone?
    @objc dynamic var userRequestDate: Date?
    @objc dynamic var eventNumber: String?
    @objc dynamic var onlineAppointmentId: String?
    @objc dynamic var isRead: Bool = false
    @objc dynamic var url: String?
    var target: Int = 0

    override static func primaryKey() -> String? {
        "id"
    }
}
