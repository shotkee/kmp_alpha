//
//  PhotoAttachment
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 18.01.2021.
//  Copyright © 2021 Redmadrobot. All rights reserved.
//

struct PhotoAttachment: Attachment {
    let id: String = UUID().uuidString
    var originalName: String?
    let type: AttachmentType = .photo
    var filename: String
    var url: URL
    let mimeType: String = "image/jpeg"
}
