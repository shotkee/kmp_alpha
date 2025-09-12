//
// RealmStoa
// AlfaStrah
//
// Created by Eugene Egorov on 05 February 2019.
// Copyright (c) 2019 Redmadrobot. All rights reserved.
//

import RealmSwift

class RealmStoa: RealmEntity {
    @objc dynamic var id: String = ""
    @objc dynamic var title: String = ""
    @objc dynamic var address: String?
    @objc dynamic var coordinate: RealmCoordinate?
    @objc dynamic var serviceHours: String = ""
    @objc dynamic var dealer: String = ""
    let phoneList: List<RealmPhone> = .init()

    override static func primaryKey() -> String? {
        "id"
    }
}
