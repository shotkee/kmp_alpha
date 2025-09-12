//
//  RealmAutoPhotoAttachmentDraft
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 12/06/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

class RealmAutoPhotoAttachmentDraft: RealmEntity {
    @objc dynamic var filename: String = ""
    @objc dynamic var fileType: Int = 0
    @objc dynamic var photoStepId: Int = 0
}
