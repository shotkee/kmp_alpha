//
//  RealmAutoEventAttachment
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 18/06/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

class RealmAutoEventAttachment: RealmEntity {
    @objc dynamic var id: String = ""
    @objc dynamic var eventReportId: String = ""
    @objc dynamic var filename: String = ""
    @objc dynamic var fileType: Int = 0
    @objc dynamic var isOptional: Bool = false

    override static func primaryKey() -> String? {
        "id"
    }
}
