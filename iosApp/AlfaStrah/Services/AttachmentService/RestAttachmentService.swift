//
//  RestAttachmentService
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 21.12.2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import UIKit
import Legacy

class RestAttachmentService: AttachmentService {
    private let rest: FullRestClient
    private let store: Store
    private let uploadDirectory: URL
    private let draftDirectory: URL
    private let tempDirectory: URL
    private let logger: TaggedLogger?
    private let eventReportLogger: EventReportLoggerService
    private let transferManager: TransferManager
    private let listeners: Subscriptions<Void> = .init()
    private let disposeBag: DisposeBag = DisposeBag()

    init(
        rest: FullRestClient,
        store: Store,
        uploadDirectory: URL,
        draftDirectory: URL,
        tempDirectory: URL,
        transferManager: TransferManager,
        logger: TaggedLogger?,
        eventReportLogger: EventReportLoggerService
    ) {
        self.rest = rest
        self.store = store
        self.uploadDirectory = uploadDirectory
        self.draftDirectory = draftDirectory
        self.tempDirectory = tempDirectory
        self.transferManager = transferManager
        self.logger = logger
        self.eventReportLogger = eventReportLogger

        // Clear temp directory
        try? FileManager.default.removeItem(at: tempDirectory)

        transferManager.subscribeToUploads { job, status in
            switch status {
                case .error:
                    break
                case .progress:
                    break
                case .finished:
                    self.uploadJobFinished(job)
            }
        }.disposed(by: disposeBag)
    }

    private func tempFileStore(_ file: String) -> SimpleAttachmentStore {
        SimpleAttachmentStore(directory: tempDirectory, name: file)
    }

    private func draftFileStore(_ file: String) -> SimpleAttachmentStore {
        SimpleAttachmentStore(directory: draftDirectory, name: file)
    }

    private func uploadFileStore(_ file: String) -> SimpleAttachmentStore {
        SimpleAttachmentStore(directory: uploadDirectory, name: file)
    }

    /// Return file name on disk
    func save(image: UIImage, name: String?) -> Attachment {
        let fileName = "Photo_\(UUID().uuidString)" + ".jpg"
        let originName = name?.contains(".jpg") ?? true ? name : "\(name ?? "").jpg"
        
        let store = tempFileStore(fileName)
        
        store.save(image) { [weak self] error in
            guard let self = self else { return }

            self.eventReportLogger.logAttachmentSavingFalure(error.localizedDescription)
        }
        
        return PhotoAttachment(
            originalName: originName,
            filename: fileName,
            url: store.url
        )
    }

    func save(jpegImageData: Data, name: String?) -> Attachment {
        let fileName = "Photo_\(UUID().uuidString)" + ".jpg"
        let originName = name?.contains(".jpg") ?? true ? name : "\(name ?? "").jpg"
        
        let store = tempFileStore(fileName)
        
        store.save(jpegImageData)
        
        return PhotoAttachment(
            originalName: originName,
            filename: fileName,
            url: store.url
        )
    }
	
    func saveFileAttachment(from url: URL, completion: @escaping (Result<Void, Error>) -> Void) -> Attachment {
        let fileName = "\(url.pathExtension.uppercased())_\(UUID().uuidString).\(url.pathExtension.lowercased())"
        let store = tempFileStore(fileName)
        
		store.copy(from: url, completion: completion)
		
        return FileAttachment(
            originalName: url.filename,
            filename: fileName,
            url: store.url
        )
    }
	
	private func saveImageAttachment(from url: URL, completion: @escaping (Result<Void, Error>) -> Void) -> Attachment {
		let fileName = "\(url.pathExtension.uppercased())_\(UUID().uuidString).\(url.pathExtension.lowercased())"
		let store = tempFileStore(fileName)
		
		store.copyImage(from: url) { result in
			completion(result)
			
			switch result {
				case .success(()):
					break
					
				case .failure(let error):
					self.logger?.debug(error.localizedDescription)
					
			}
		}
		
		return PhotoAttachment(
			originalName: url.filename,
			filename: fileName,
			url: store.url
		)
	}

    func load(attachment: Attachment) -> Data? {
        tempFileStore(attachment.filename).data()
    }

    func attachmentExists(_ attachment: Attachment) -> Bool {
        tempFileStore(attachment.filename).exists
    }

    func delete(attachment: Attachment) {
        tempFileStore(attachment.filename).remove()
    }

    /// Save photos to persistant storage
    func saveDraftPhotos(_ photos: [AutoPhotoAttachmentDraft]) {
        for draftPhoto in photos {
			draftFileStore(draftPhoto.filename).copy(from: tempFileStore(draftPhoto.filename).url) { _ in }
        }
    }

    func loadAttachmentFromDraft(_ draftPhoto: AutoPhotoAttachmentDraft) -> Attachment? {
        let store = tempFileStore(draftPhoto.filename)
		store.copy(from: draftFileStore(draftPhoto.filename).url) { _ in }
        return PhotoAttachment(filename: draftPhoto.filename, url: store.url)
    }

    func deleteDraftPhotos(_ photos: [AutoPhotoAttachmentDraft]) {
        photos.forEach { draftPhoto in
            draftFileStore(draftPhoto.filename).remove()
        }
    }

    private func savePhotoForUpload(_ filename: String) {
		uploadFileStore(filename).copy(from: tempFileStore(filename).url) { _ in }
    }

    func addToUploadQueue(attachments: [AutoEventAttachment]) {
        do {
            try store.write { transaction in
                try transaction.insert(attachments)
            }

            // Copy photo to persistant folder
            attachments.map { $0.filename }.forEach { savePhotoForUpload($0) }

            let grouped = Dictionary(grouping: attachments) { $0.eventReportId }
            for eventReportId in grouped.keys {
                log("Saved attachments (count = \(attachments.count)) to Realm DB before sending on server.",
                    eventReportId: eventReportId)
                log("Start sending attachments (conunt = \(attachments.count)) on server", eventReportId: eventReportId)
                updateUploadStatus(
                    eventReportId: eventReportId,
                    documentsCount: grouped[eventReportId]?.count ?? 0,
                    uploadedDocumentsCount: 0
                )
            }
            transferManager.upload(attachments: attachments)
        } catch let error {
            if let eventReportId = attachments.first?.eventReportId {
                log("❌ Failed to save attachment info to Realm DB. Error: \(error)", eventReportId: eventReportId)
            }
        }
    }

    private func cachedAutoEventAttachments() -> [AutoEventAttachment] {
        var attachments: [AutoEventAttachment] = []
        try? store.read { transaction in
            attachments = try transaction.select()
        }
        return attachments
    }

    private func delete(attachment: AutoEventAttachment) {
        log("Deleting attachment: \(attachment.id) and file: \(attachment.filename)", eventReportId: attachment.eventReportId)
        uploadFileStore(attachment.filename).remove()
        try? store.write { transaction in
            try transaction.delete(type: AutoEventAttachment.self, id: attachment.id)
        }
    }

    func addToUploadQueue(attachments: [PassengersEventAttachment]) {
        try? store.write { transaction in
            try transaction.insert(attachments)
        }

        // Copy photo to persistant folder
        attachments.map { $0.filename }.forEach { savePhotoForUpload($0) }

        let grouped = Dictionary(grouping: attachments) { $0.eventReportId }
        for eventReportId in grouped.keys {
            log("Saved attachments (count = \(attachments.count)) to Realm DB before sending on server.",
            eventReportId: eventReportId)
            log("Start sending attachments (conunt = \(attachments.count)) on server", eventReportId: eventReportId)
            updateUploadStatus(
                eventReportId: eventReportId,
                documentsCount: grouped[eventReportId]?.count ?? 0,
                uploadedDocumentsCount: 0
            )
        }
        transferManager.upload(attachments: attachments)
    }

    private func cachedPassengersEventAttachments() -> [PassengersEventAttachment] {
        var attachments: [PassengersEventAttachment] = []
        try? store.read { transaction in
            attachments = try transaction.select()
        }
        return attachments
    }

    private func delete(attachment: PassengersEventAttachment) {
        log("Deleting attachment: \(attachment.id) and file: \(attachment.filename)", eventReportId: attachment.eventReportId)
        uploadFileStore(attachment.filename).remove()
        try? store.write { transaction in
            try transaction.delete(type: PassengersEventAttachment.self, id: attachment.id)
        }
    }

    func addToUploadQueue(attachments: [AccidentEventAttachment]) {
        try? store.write { transaction in
            try transaction.insert(attachments)
        }

        // Copy photo to persistant folder
        attachments.map { $0.filename }.forEach { savePhotoForUpload($0) }

        let grouped = Dictionary(grouping: attachments) { $0.eventReportId }
        for eventReportId in grouped.keys {
            log("Saved attachments (count = \(attachments.count)) to Realm DB before sending on server.",
            eventReportId: eventReportId)
            log("Start sending attachments (conunt = \(attachments.count)) on server", eventReportId: eventReportId)
            updateUploadStatus(
                eventReportId: eventReportId,
                documentsCount: grouped[eventReportId]?.count ?? 0,
                uploadedDocumentsCount: 0
            )
        }
        transferManager.upload(attachments: attachments)
    }

    private func cachedAccidentEventAttachments() -> [AccidentEventAttachment] {
        var attachments: [AccidentEventAttachment] = []
        try? store.read { transaction in
            attachments = try transaction.select()
        }
        return attachments
    }

    private func delete(attachment: AccidentEventAttachment) {
        log("Deleting attachment: \(attachment.id) and file: \(attachment.filename)", eventReportId: attachment.eventReportId)
        uploadFileStore(attachment.filename).remove()
        try? store.write { transaction in
            try transaction.delete(type: AccidentEventAttachment.self, id: attachment.id)
        }
    }

    private func uploadJobFinished(_ job: UploadTransferManager.Job) {
        // Update status
        updateUploadStatus(eventReportId: job.eventReportId, documentsCount: 0, uploadedDocumentsCount: 1)
        switch job.attachmentType {
            case .auto:
                if let attachment = cachedAutoEventAttachments().first(where: { $0.id == job.attachmentId }) {
                    delete(attachment: attachment)
                }
            case .passangers:
                if let attachment = cachedPassengersEventAttachments().first(where: { $0.id == job.attachmentId }) {
                    delete(attachment: attachment)
                }
            case .accident:
                if let attachment = cachedAccidentEventAttachments().first(where: { $0.id == job.attachmentId }) {
                    delete(attachment: attachment)
                }
        }

        // Notify listeners
        listeners.fire(())
    }

    func stopUploadTasks() {
        transferManager.invalidateAll()
    }

    // MARK: - Upload status

    func updateUploadStatus(eventReportId: String, documentsCount: Int, uploadedDocumentsCount: Int) {
        var status: AttachmentsUploadStatus?
        do {
        try store.read { transaction in
            let statuses: [AttachmentsUploadStatus] = try transaction.select(
                predicate: NSPredicate(format: "eventReportId = %@", eventReportId)
            )
            status = statuses.first
            status?.totalDocumentsCount += documentsCount
            status?.uploadedDocumentsCount += uploadedDocumentsCount
        }

        let newStatus = status ?? AttachmentsUploadStatus(eventReportId: eventReportId, totalDocumentsCount: documentsCount,
            uploadedDocumentsCount: uploadedDocumentsCount)
        try store.write { transaction in
            try transaction.upsert(newStatus)
        }
        } catch let error {
            log("❌ Failed to save AttachmentsUploadStatus info to Realm DB. Error: \(error)", eventReportId: eventReportId)
        }
    }

    func uploadStatus(eventReportId: String) -> AttachmentsUploadStatus? {
        var uploadStatus: AttachmentsUploadStatus?
        try? self.store.read { transaction in
            let statuses: [AttachmentsUploadStatus] = try transaction.select(
                predicate: NSPredicate(format: "eventReportId = %@", eventReportId)
            )
            uploadStatus = statuses.first
        }
        return uploadStatus
    }

    func subscribeToUploads(_ listener: @escaping () -> Void) -> Subscription {
        listeners.add(listener)
    }

    // MARK: - Logs

    private func log(_ message: String, eventReportId: String? = nil) {
        logger?.debug(message)
        eventReportLogger.addLog(message, eventReportId: eventReportId)
    }

    // MARK: - Updatable

    func updateService(isUserAuthorized: Bool, completion: @escaping (Result<Void, ServiceUpdateError>) -> Void) {
        completion(.failure(.notImplemented))
    }

    func performActionAfterAppIsReady(isUserAuthorized: Bool, completion: @escaping (Result<Void, ServiceUpdateError>) -> Void) {
        completion(.failure(.notImplemented))
    }

    func erase(logout: Bool) {
        if logout {
            stopUploadTasks()
        }
        try? FileManager.default.removeItem(at: uploadDirectory)
        try? FileManager.default.removeItem(at: draftDirectory)
        try? FileManager.default.removeItem(at: tempDirectory)
        try? store.write { transaction in
            try transaction.delete(type: AutoEventAttachment.self)
            try transaction.delete(type: PassengersEventAttachment.self)
            try transaction.delete(type: AttachmentsUploadStatus.self)
        }
    }
    
    func size(of data: Data, in units: ByteCountFormatter.Units) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [units]
        formatter.countStyle = .file
        
        return formatter.string(fromByteCount: Int64(data.count))
    }
    
    func size(from url: URL) -> Int64? {
        let resource = try? url.resourceValues(forKeys: [.fileSizeKey])
        
        if let size = resource?.fileSize {
            return Int64(size)
        }
        return nil
    }
	
	// MARK: - Attachments from urls
	func saveFiles(from urls: [URL]) -> [Attachment] {
		var attachments: [Attachment] = []
		
		for url in urls where FileManager.default.fileExists(atPath: url.path)  {
			if url.isImageFile {	// need compression etc
				attachments.append(saveImageAttachment(from: url) { _ in })
			} else {
				attachments.append(saveFileAttachment(from: url) { _ in })
			}
		}
		
		return attachments
	}
	
	func saveFile(from url: URL, completion: @escaping (Result<Void, Error>) -> Void) -> Attachment? {
		if FileManager.default.fileExists(atPath: url.path) { // is local file?
			if url.isImageFile {	// need compression etc
				return saveImageAttachment(from: url, completion: completion)
			} else {
				return saveFileAttachment(from: url, completion: completion)
			}
		}
		
		return nil
	}
}
