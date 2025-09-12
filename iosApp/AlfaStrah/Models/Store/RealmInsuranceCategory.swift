//
//  RealmInsuranceCategory
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 13/02/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import RealmSwift

class RealmInsuranceCategory: RealmEntity {
    @objc dynamic var id: String = ""
    @objc dynamic var title: String = ""
    @objc dynamic var termsURL: String?
    @objc dynamic var sortPriority: Int = 0
    @objc dynamic var daysLeft: Int = 0
    let productIds: List<String> = .init()
    @objc dynamic var kind: Int = 0
    @objc dynamic var subtitle: String = ""

    override static func primaryKey() -> String? {
        "id"
    }
}
