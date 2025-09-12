//
//  AutoPhotoAttachmentDraft
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 11/06/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

struct AutoPhotoAttachmentDraft: Entity, Equatable {
    var filename: String
    var fileType: AttachmentPhotoType
    var photoStepId: Int
}
