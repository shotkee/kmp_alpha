//
//  RealmAccidentEventAttachment
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 18.11.2020.
//  Copyright © 2020 Redmadrobot. All rights reserved.
//

class RealmAccidentEventAttachment: RealmEntity {
    @objc dynamic var id: String = ""
    @objc dynamic var eventReportId: String = ""
    @objc dynamic var filename: String = ""

    override static func primaryKey() -> String? {
        "id"
    }
}
