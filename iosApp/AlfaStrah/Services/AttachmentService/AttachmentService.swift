//
//  AttachmentService
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 14/06/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import UIKit
import Legacy

protocol AttachmentService: Updatable {
    /// Return file name on disk
    func save(image: UIImage, name: String?) -> Attachment
    func save(jpegImageData: Data, name: String?) -> Attachment
	func saveFileAttachment(from url: URL, completion: @escaping (Result<Void, Error>) -> Void) -> Attachment

    func load(attachment: Attachment) -> Data?
    func attachmentExists(_ attachment: Attachment) -> Bool
    func delete(attachment: Attachment)
    func size(from url: URL) -> Int64?

    /// Save photos to persistant storage
    func saveDraftPhotos(_ photos: [AutoPhotoAttachmentDraft])
    func loadAttachmentFromDraft(_ draftPhoto: AutoPhotoAttachmentDraft) -> Attachment?
    func deleteDraftPhotos(_ photos: [AutoPhotoAttachmentDraft])

    // Upload control
    func addToUploadQueue(attachments: [AutoEventAttachment])
    func addToUploadQueue(attachments: [PassengersEventAttachment])
    func addToUploadQueue(attachments: [AccidentEventAttachment])
    func uploadStatus(eventReportId: String) -> AttachmentsUploadStatus?
    func subscribeToUploads(_ listener: @escaping () -> Void) -> Subscription
    func stopUploadTasks()
    
    // Upload files
	func saveFiles(from urls: [URL]) -> [Attachment]
	func saveFile(from url: URL, completion: @escaping (Result<Void, Error>) -> Void) -> Attachment?
}
