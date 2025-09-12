//
//  RealmPassengersEventAttachment
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 21/06/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import RealmSwift

class RealmPassengersEventAttachment: RealmEntity {
    @objc dynamic var id: String = ""
    @objc dynamic var eventReportId: String = ""
    @objc dynamic var documentId: Int = 0
    @objc dynamic var filename: String = ""
    @objc dynamic var documentsCount: Int = 0

    override static func primaryKey() -> String? {
        "id"
    }
}
