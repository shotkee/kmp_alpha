//
//  TransferManager.swift
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 12.12.2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import Legacy

enum DataTransfer {
    enum Status {
        case progress(bytes: Int64, outOfBytes: Int64)
        case error(Error?)
        case finished
    }

    enum Errors: Error {
        case wrongParameters
        case backend(Error?)
        case backgroundTask
        case cantSerializeToFile(Error?)
    }
}

protocol TransferManager: AnyObject {
    func upload(attachments: [AutoEventAttachment])
    func upload(attachments: [PassengersEventAttachment])
    func upload(attachments: [AccidentEventAttachment])
    func subscribeToUploads(_ listener: @escaping ((UploadTransferManager.Job, DataTransfer.Status)) -> Void) -> Subscription
    func reconnectWithBackgroundSession(identifier: String, completion: @escaping () -> Void)
    func invalidateAll()
}
