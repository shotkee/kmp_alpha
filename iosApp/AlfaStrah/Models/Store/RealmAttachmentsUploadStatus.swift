//
//  RealmAttachmentsUploadStatus
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 30.12.2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

class RealmAttachmentsUploadStatus: RealmEntity {
    @objc dynamic var eventReportId: String = ""
    @objc dynamic var totalDocumentsCount: Int = 0
    @objc dynamic var uploadedDocumentsCount: Int = 0

    override static func primaryKey() -> String? {
        "eventReportId"
    }
}
