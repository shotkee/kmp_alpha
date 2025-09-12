//
//  Attachment
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 03.02.2021.
//  Copyright © 2021 Redmadrobot. All rights reserved.
//

enum AttachmentType {
    case photo
    case file
}

protocol Attachment {
    var id: String { get }
    var originalName: String? { get set }
    var filename: String { get set }
    var url: URL { get set }
    var mimeType: String { get }
    var type: AttachmentType { get }
}
