//
//  UploadTransferManager.swift
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 17.12.2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import Foundation
import Legacy
import os

enum AttachmentTransferError: Error {
    case badContentType
    case noBody
    case errorInAscii
    case cantCreateTemporaryFile
}

struct TransferredAttachment {
    var parameterName: String
    var filename: String
    var contentType: String

    var dataFileUrl: URL
}

class UploadTransferManager {
    private var logger: TaggedLogger?
    private let eventReportLogger: EventReportLoggerService
    private var foregroundSession: URLSession
    private var backgroundSession: URLSession
    private let directory: URL
    private let authorizer: HttpRequestAuthorizer

    private let listeners: Subscriptions<(Job, DataTransfer.Status)> = .init()

    init(
        foregroundSession: URLSession,
        backgroundSession: URLSession,
        directory: URL,
        authorizer: HttpRequestAuthorizer,
        logger: TaggedLogger?,
        eventReportLogger: EventReportLoggerService
    ) {
        self.foregroundSession = foregroundSession
        self.backgroundSession = backgroundSession
        self.directory = directory
        self.authorizer = authorizer
        self.eventReportLogger = eventReportLogger
        self.logger = logger.map { SimpleTaggedLogger(logger: $0, for: self) }
    }

    deinit {
        logger?.debug("")
    }

    private lazy var foregroundJobs: PersistentConcurrentDictionary<Job> = .init(
        fileUrl: directory.appendingPathComponent("uploadJobsForeground", isDirectory: false)
    )
    private lazy var backgroundJobs: PersistentConcurrentDictionary<Job> = .init(
        fileUrl: directory.appendingPathComponent("uploadJobsBackground", isDirectory: false)
    )

    func hasJob(url: URL, attachmentId: String?) -> Bool {
        let predicate: (Job) -> Bool = { $0.urlToUpload == url && $0.attachmentId == attachmentId }
        return foregroundJobs.containsValue(predicate) || backgroundJobs.containsValue(predicate)
    }

    func restartKilledForegroundTransfers() {
        // Transfer all foreground jobs to background
        let nonRunningForegroundJobs = foregroundJobs.values
        for job in nonRunningForegroundJobs {
            if let taskId = job.taskInfo?.sessionTaskId {
                transferToBackgroundUpload(foregroundTaskId: taskId)
            }
        }

        // Restart all killed background jobs
        let nonRunningBackgroundJobs = backgroundJobs.values
        for job in nonRunningBackgroundJobs {
            if let taskId = job.taskInfo?.sessionTaskId {
                backgroundSession.getAllTasks {
                    if !$0.contains(where: { $0.taskIdentifier == taskId }) {
                        self.restartBackgroundUpload(backgroundTaskId: taskId)
                    }
                }

            }
        }
    }

    func upload(job: Job) {
        let predicate: (Job) -> Bool = { $0.attachmentId == job.attachmentId }
        guard !foregroundJobs.containsValue(predicate), !backgroundJobs.containsValue(predicate) else {
            log("Already uploading file with url: \(job.urlToUpload)", eventReportId: job.eventReportId)
            return
        }
        
        let uploadInfo = job.uploadInfo
        let result = multipartEncode(fileUrl: job.urlToUpload, parameters: uploadInfo.parameters)
                
        guard let (serializedUrl, serializedContentType) = result.value else {
            cleanup(job: job, isBackground: false, removeData: true)
            notifyListeners(status: .error(DataTransfer.Errors.cantSerializeToFile(result.error)), job: job, task: nil)
            return
        }
        
        guard FileManager.default.fileExistsAtURL(serializedUrl) else {
            cleanup(job: job, isBackground: false, removeData: true)
            notifyListeners(status: .error(DataTransfer.Errors.cantSerializeToFile(nil)), job: job, task: nil)
            return
        }

        var request = authorizer.authorize(request: URLRequest(url: uploadInfo.url))
        request.httpMethod = "POST"
        request.addValue(serializedContentType, forHTTPHeaderField: "Content-Type")

        let task = foregroundSession.uploadTask(with: request, fromFile: serializedUrl)
        let taskId = task.taskIdentifier

        let backgroundTask = BackgroundTask(name: "Uploading \(uploadInfo.url)") {
            self.transferToBackgroundUpload(foregroundTaskId: taskId)
        }

        var uploadJob = job
        uploadJob.taskInfo = .init(
            sessionTaskId: taskId,
            multipartUploadingFileUrl: serializedUrl,
            serializedContentType: serializedContentType,
            backgroundIdRawValue: backgroundTask.rawId,
            wasMovedToBackground: false
        )
        foregroundJobs[taskId] = uploadJob
        task.resume()
        log("Foreground uploading (task: \(taskId); attachment: \(job.attachmentId)) \(serializedUrl.lastPathComponent)",
            eventReportId: job.eventReportId)
    }

    private func transferToBackgroundUpload(foregroundTaskId: Int) {
        guard let job = foregroundJobs[foregroundTaskId] else {
            log("Can't send upload task to background")
            return
        }

        log("Transferring foreground upload task \(foregroundTaskId) to background. Attachment: \(job.attachmentId)",
            eventReportId: job.eventReportId)
        cleanup(job: job, isBackground: false, removeData: false)

        if let foregroundTaskId = job.taskInfo?.sessionTaskId {
            foregroundSession.getAllTasks { $0.first { $0.taskIdentifier == foregroundTaskId }?.cancel() }
        }

        backgroundUpload(job: job)
    }

    private func backgroundUpload(job: Job) {
        guard let taskInfo = job.taskInfo else {
            notifyListeners(status: .error(DataTransfer.Errors.wrongParameters), job: job, task: nil)
            return
        }
        guard FileManager.default.fileExistsAtURL(taskInfo.multipartUploadingFileUrl) else {
            cleanup(job: job, isBackground: true, removeData: true)
            notifyListeners(status: .error(DataTransfer.Errors.cantSerializeToFile(nil)), job: job, task: nil)
            return
        }

        var uploadJob = job
        let uploadInfo = job.uploadInfo
        var request = authorizer.authorize(request: URLRequest(url: uploadInfo.url))
        request.httpMethod = "POST"
        request.addValue(taskInfo.serializedContentType, forHTTPHeaderField: "Content-Type")

        let task = backgroundSession.uploadTask(with: request, fromFile: taskInfo.multipartUploadingFileUrl)
        let taskId = task.taskIdentifier

        uploadJob.taskInfo = .init(
            sessionTaskId: taskId,
            multipartUploadingFileUrl: taskInfo.multipartUploadingFileUrl,
            serializedContentType: taskInfo.serializedContentType,
            backgroundIdRawValue: nil,
            wasMovedToBackground: false
        )
        backgroundJobs[taskId] = uploadJob
        task.resume()
        let fileName = taskInfo.multipartUploadingFileUrl.lastPathComponent
        log("Background uploading (task: \(taskId); attachment: \(job.attachmentId)) \(fileName)",
            eventReportId: uploadJob.eventReportId)
    }

    private func restartBackgroundUpload(backgroundTaskId: Int) {
        guard let job = backgroundJobs[backgroundTaskId] else {
            log("Can't restart background upload task")
            return
        }

        log("Restarting background upload task \(backgroundTaskId). Attachment: \(job.attachmentId)",
        eventReportId: job.eventReportId)
        cleanup(job: job, isBackground: true, removeData: false)
        backgroundUpload(job: job)
    }

    private func multipartEncode(
        fileUrl: URL,
        parameters: [String: String]
    ) -> Result<(url: URL, contentType: String), AttachmentTransferError> {
        let serializer = MultipartFileSerializer()
        let fileName = UUID().uuidString
        let serializerResult = serializer.serializeToFile(
            file: TransferredAttachment(
                parameterName: "file",
                filename: fileName,
                contentType: "application/octet-stream",
                dataFileUrl: fileUrl
            ),
            parameters: parameters
        )
        return serializerResult.map { ($0, serializer.contentType) }
    }
    
    private func cleanup(job: Job, isBackground: Bool, removeData: Bool) {
        guard let taskInfo = job.taskInfo else { return }

        log("Deleting \(isBackground ? "Background" : "Foreground") job (task: \(taskInfo.sessionTaskId); attachment: \(job.attachmentId))",
            eventReportId: job.eventReportId)
        if isBackground {
            backgroundJobs[taskInfo.sessionTaskId] = nil
        } else {
            foregroundJobs[taskInfo.sessionTaskId] = nil
        }

        if removeData {
            do {
                log("Deleting file \(taskInfo.multipartUploadingFileUrl.lastPathComponent)", eventReportId: job.eventReportId)
                try FileManager.default.removeItem(at: taskInfo.multipartUploadingFileUrl)
            } catch {
                log("Can't delete temporary file: \(taskInfo.multipartUploadingFileUrl)", eventReportId: job.eventReportId)
            }
        }

        BackgroundTask.endTask(rawId: taskInfo.backgroundIdRawValue)
    }

    // MARK: - Invalidation

    func invalidateAllTransfers() {
        foregroundJobs.removeAll()
        backgroundJobs.removeAll()
    }

    // MARK: - Working with URLSession delegate methods

    private func job(isBackground: Bool, task: URLSessionTask) -> Job? {
        let taskId = task.taskIdentifier
        return isBackground ? backgroundJobs[taskId] : foregroundJobs[taskId]
    }

    func didSend(bytes: Int64, outOfBytes: Int64, isBackground: Bool, task: URLSessionTask) {
        guard let job = job(isBackground: isBackground, task: task) else { return }

        notifyListeners(status: .progress(bytes: bytes, outOfBytes: outOfBytes), job: job, task: nil)
    }

    func didComplete(isBackground: Bool, task: URLSessionTask) {
        guard let job = job(isBackground: isBackground, task: task) else { return }

        log("\(isBackground ? "Background" : "Foreground") upload task \(task.taskIdentifier) finished. Attachment: \(job.attachmentId)",
            eventReportId: job.eventReportId)
        notifyListeners(status: .finished, job: job, task: nil)
        cleanup(job: job, isBackground: isBackground, removeData: true)
    }

    func didFail(_ error: Error, isBackground: Bool, task: URLSessionTask) {
        guard let job = job(isBackground: isBackground, task: task) else { return }

        let type = isBackground ? "Background" : "Foreground"
        log("\(type) upload task \(task.taskIdentifier) error: \(error.localizedDescription). Attachment: \(job.attachmentId)",
            eventReportId: job.eventReportId)
        if !isBackground {
            transferToBackgroundUpload(foregroundTaskId: task.taskIdentifier)
        } else {
            restartBackgroundUpload(backgroundTaskId: task.taskIdentifier)
        }

        if !isBackground && ((error as? URLError)?.code == URLError.cancelled) {
            notifyListeners(status: .error(error), job: job, task: nil)
        }
    }

    func subscribe(_ listener: @escaping ((UploadTransferManager.Job, DataTransfer.Status)) -> Void) -> Subscription {
        listeners.add(listener)
    }

    func notifyListeners(status: DataTransfer.Status, job: Job, task: URLSessionTask?) {
        DispatchQueue.main.async {
            self.listeners.fire((job, status))
        }
    }

    private func log(_ message: String, eventReportId: String? = nil) {
        logger?.debug(message)
        eventReportLogger.addLog(message, eventReportId: eventReportId)
    }
}
