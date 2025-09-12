//
//  FileAttachment
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 03.02.2021.
//  Copyright © 2021 Redmadrobot. All rights reserved.
//

import MobileCoreServices

struct FileAttachment: Attachment {
    let id: String = UUID().uuidString
    var originalName: String?
    let type: AttachmentType = .file
    var filename: String
    var url: URL
    var mimeType: String {
        return mimeTypeForPath(url: url)
    }
    
    private func mimeTypeForPath(url: URL) -> String {
        if let uti = UTTypeCreatePreferredIdentifierForTag(
            kUTTagClassFilenameExtension,
            url.pathExtension as NSString,
            nil
        )?.takeRetainedValue() {
            if let mimetype = UTTypeCopyPreferredTagWithClass(uti, kUTTagClassMIMEType)?.takeRetainedValue() {
                return mimetype as String
            }
        }
        return "application/octet-stream"
    }
}
