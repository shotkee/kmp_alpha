//
//  UrlSessionTransfersDelegate.swift
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 17.12.2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import Foundation

class UrlSessionTransfersDelegate: NSObject, URLSessionDataDelegate {
    private let backgroundSessionIdentifier: String

    init(backgroundSessionIdentifier: String) {
        self.backgroundSessionIdentifier = backgroundSessionIdentifier
        super.init()
    }

    weak var uploadTransferManager: UploadTransferManager?
    var didFinishEventsCompletion: (() -> Void)?

    func isBackground(session: URLSession) -> Bool {
        session.configuration.identifier == backgroundSessionIdentifier
    }

    func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        didSendBodyData bytesSent: Int64,
        totalBytesSent: Int64,
        totalBytesExpectedToSend: Int64
    ) {
        let background = isBackground(session: session)
        uploadTransferManager?.didSend(bytes: totalBytesSent, outOfBytes: totalBytesExpectedToSend, isBackground: background, task: task)
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        let background = isBackground(session: session)

        if let error = error {
            uploadTransferManager?.didFail(error, isBackground: background, task: task)
        } else {
            uploadTransferManager?.didComplete(isBackground: background, task: task)
        }
    }

    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        // Note that because urlSessionDidFinishEvents(forBackgroundURLSession:) may be called on a secondary queue,
        // it needs to explicitly execute the handler (which was received from a UIKit method) on the main queue.
        DispatchQueue.main.async {
            self.didFinishEventsCompletion?()
        }
    }
}
