//
//  RealmPassengersEventDraft
//  AlfaStrah
//
//  Created by Evgeny Ivanov on 04/06/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import RealmSwift

class RealmPassengersEventDraft: RealmEntity {
    @objc dynamic var id: String = ""
    @objc dynamic var insuranceId: String = ""
    @objc dynamic var riskId: String = ""
    @objc dynamic var date: Date = Date()
    let values: List<RealmRiskValue> = .init()

    override static func primaryKey() -> String? {
        "id"
    }
}

class RealmRiskValue: RealmEntity {
    @objc dynamic var riskId: String = ""
    @objc dynamic var categoryId: String = ""
    @objc dynamic var dataId: String = ""
    @objc dynamic var optionId: String?
    @objc dynamic var value: String = ""
}
