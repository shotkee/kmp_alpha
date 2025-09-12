//
//  AttachmentsUploadStatus
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 30.12.2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

struct AttachmentsUploadStatus: Entity {
    var eventReportId: String
    var totalDocumentsCount: Int
    var uploadedDocumentsCount: Int

    var finished: Bool {
        uploadedDocumentsCount == totalDocumentsCount
    }
}
