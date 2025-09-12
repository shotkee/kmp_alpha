//
//  FileUploadResponse
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 18/06/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

// sourcery: transformer
struct FileUploadResponse {
    var success: Bool
    var message: String
    // sourcery: transformer.name = "document_id"
    var documentId: String
}
