//
//  RealmAttachmentEventLog
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 28.11.2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

class RealmAttachmentEventLog: RealmEntity {
    @objc dynamic var eventReportId: String = ""
    @objc dynamic var message: String = ""
    @objc dynamic var closed: Bool = false

    override static func primaryKey() -> String? {
        "eventReportId"
    }
}
