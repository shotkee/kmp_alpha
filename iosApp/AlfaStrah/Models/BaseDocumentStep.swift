//
//  BaseDocumentStep
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 10.11.2020.
//  Copyright © 2020 Redmadrobot. All rights reserved.
//

class BaseDocumentStep {
    var title: String
    var minDocuments: Int
    var maxDocuments: Int
    var attachments: [Attachment]

    init(title: String, minDocuments: Int, maxDocuments: Int, attachments: [Attachment]) {
        self.title = title
        self.minDocuments = minDocuments
        self.maxDocuments = maxDocuments
        self.attachments = attachments
    }

    var isReady: Bool {
        attachments.count >= minDocuments
    }

    enum Status {
        case ready
        case optional
        case required
    }

    var status: Status {
        if isReady && !attachments.isEmpty {
            return .ready
        } else if !attachments.isEmpty {
            return .required
        } else {
            return .optional
        }
    }
}
