//
//  UrlSessionTransferManager.swift
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 12.12.2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import Legacy
import os

class UrlSessionTransferManager: TransferManager {
    private var logger: TaggedLogger?
    private let eventReportLogger: EventReportLoggerService
    private let foregroundSession: URLSession
    private let backgroundSession: URLSession
    private let backgroundSessionIdentifier: String
    private let uploadTransferManager: UploadTransferManager
    private let baseUrl: URL
    private let directory: URL
    private let authorizer: HttpRequestAuthorizer
    private var backgroundSessionCompletionHandler: (() -> Void)?

    init(
        backgroundSessionIdentifier: String,
        baseUrl: URL,
        directory: URL,
        authorizer: HttpRequestAuthorizer,
        logger: TaggedLogger?,
        eventReportLogger: EventReportLoggerService
    ) {
        self.backgroundSessionIdentifier = backgroundSessionIdentifier
        self.baseUrl = baseUrl
        self.directory = directory
        self.authorizer = authorizer
        self.logger = logger
        self.eventReportLogger = eventReportLogger

        let delegate = UrlSessionTransfersDelegate(backgroundSessionIdentifier: backgroundSessionIdentifier)
        foregroundSession = UrlSessionTransferManager.foregroundSession(delegate: delegate)
        backgroundSession = UrlSessionTransferManager.backgroundSession(
            sessionIdentifier: backgroundSessionIdentifier,
            delegate: delegate
        )

        uploadTransferManager = UploadTransferManager(
            foregroundSession: foregroundSession,
            backgroundSession: backgroundSession,
            directory: directory,
            authorizer: authorizer,
            logger: logger,
            eventReportLogger: eventReportLogger
        )

        delegate.uploadTransferManager = uploadTransferManager
        delegate.didFinishEventsCompletion = { [weak self] in
            guard let self = self else { return }

            self.log("urlSessionDidFinishEvents called for background session")
            self.backgroundSessionCompletionHandler?()
            self.backgroundSessionCompletionHandler = nil
        }

        restartKilledForegroundTransfers()

        self.logger?.debug("")
    }

    deinit {
        logger?.debug("")
    }

    private static func foregroundSession(delegate: URLSessionDelegate) -> URLSession {
        let configuration = URLSessionConfiguration.default
        configuration.urlCache = nil
        configuration.httpShouldSetCookies = false
        configuration.requestCachePolicy = .returnCacheDataElseLoad
        configuration.allowsCellularAccess = true
        configuration.timeoutIntervalForRequest = 300

        let session = URLSession(configuration: configuration, delegate: delegate, delegateQueue: nil)
        return session
    }

    private static func backgroundSession(
        sessionIdentifier: String,
        delegate: URLSessionDelegate
    ) -> URLSession {
        let configuration = URLSessionConfiguration.background(withIdentifier: sessionIdentifier)
        configuration.urlCache = nil
        configuration.httpShouldSetCookies = false
        configuration.requestCachePolicy = .returnCacheDataElseLoad
        configuration.sessionSendsLaunchEvents = true
        configuration.allowsCellularAccess = true
        configuration.shouldUseExtendedBackgroundIdleMode = true
        // wait for optimal conditions to perform the transfer, such as when the device is plugged in or connected to Wi-Fi
        configuration.isDiscretionary = true

        let session = URLSession(configuration: configuration, delegate: delegate, delegateQueue: nil)
        return session
    }

    private func fileStore(_ file: String) -> SimpleAttachmentStore {
        SimpleAttachmentStore(directory: directory, name: file)
    }

    func restartKilledForegroundTransfers() {
        log("Fixing lost transfers")

        uploadTransferManager.restartKilledForegroundTransfers()
    }

    // MARK: - Uploading

    func upload(attachments: [AutoEventAttachment]) {
        for attachment in attachments {
            let uploadPath = attachment.isOptional
                ? "event_reports/\(attachment.eventReportId)/attach_file_optional"
                : "event_reports/\(attachment.eventReportId)/attach_file"

            let uploadInfo = UploadTransferManager.Job.UploadInfo(
                url: baseUrl.appendingPathComponent(uploadPath),
                parameters: [ "type": "\(attachment.fileType.rawValue)" ]
            )

            let uploadJob = UploadTransferManager.Job(
                attachmentId: attachment.id,
                attachmentType: .auto,
                eventReportId: attachment.eventReportId,
                urlToUpload: fileStore(attachment.filename).url,
                uploadInfo: uploadInfo
            )

            uploadTransferManager.upload(job: uploadJob)
        }
    }

    func upload(attachments: [PassengersEventAttachment]) {
        for attachment in attachments {
            let uploadPath = "event_reports/\(attachment.eventReportId)/risks/document"

            let uploadInfo = UploadTransferManager.Job.UploadInfo(
                url: baseUrl.appendingPathComponent(uploadPath),
                parameters: [
                    "risk_document_id": "\(attachment.documentId)",
                    "documents_count": "\(attachment.documentsCount)"
                ]
            )

            let uploadJob = UploadTransferManager.Job(
                attachmentId: attachment.id,
                attachmentType: .passangers,
                eventReportId: attachment.eventReportId,
                urlToUpload: fileStore(attachment.filename).url,
                uploadInfo: uploadInfo
            )

            uploadTransferManager.upload(job: uploadJob)
        }
    }

    func upload(attachments: [AccidentEventAttachment]) {
        for attachment in attachments {
            let uploadPath = "api/event_reports/ns/\(attachment.eventReportId)/attach_file"

            let uploadInfo = UploadTransferManager.Job.UploadInfo(
                url: baseUrl.appendingPathComponent(uploadPath),
                parameters: [:]
            )

            let uploadJob = UploadTransferManager.Job(
                attachmentId: attachment.id,
                attachmentType: .accident,
                eventReportId: attachment.eventReportId,
                urlToUpload: fileStore(attachment.filename).url,
                uploadInfo: uploadInfo
            )

            uploadTransferManager.upload(job: uploadJob)
        }
    }

    // MARK: - Subscriptions

    func subscribeToUploads(_ listener: @escaping ((UploadTransferManager.Job, DataTransfer.Status)) -> Void) -> Subscription {
        uploadTransferManager.subscribe(listener)
    }

    func reconnectWithBackgroundSession(identifier: String, completion: @escaping () -> Void) {
        guard identifier == backgroundSessionIdentifier else { return }

        log("Saved backgroundSessionCompletionHandler")
        backgroundSessionCompletionHandler = completion
    }

    // MARK: - Invalidation

    func invalidateAll() {
        foregroundSession.getAllTasks { $0.forEach { $0.cancel() } }

        uploadTransferManager.invalidateAllTransfers()
    }

    private func log(_ message: String, eventReportId: String? = nil) {
        logger?.debug(message)
        eventReportLogger.addLog(message, eventReportId: eventReportId)
    }
}
