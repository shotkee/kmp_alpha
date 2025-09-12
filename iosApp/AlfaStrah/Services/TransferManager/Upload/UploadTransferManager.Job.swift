//
//  UploadTransferManager.Job.swift
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 17.12.2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

extension UploadTransferManager {
    struct Job: Codable {
        struct UploadInfo: Codable {
            var url: URL
            var parameters: [String: String]
        }

        struct TaskInfo: Codable {
            var sessionTaskId: Int
            var multipartUploadingFileUrl: URL
            var serializedContentType: String
            var backgroundIdRawValue: Int?
            var wasMovedToBackground: Bool
        }

        enum AttachmentType: Int, Codable {
            case auto = 0
            case passangers = 1
            case accident = 2
        }

        var attachmentId: String
        var attachmentType: AttachmentType
        var eventReportId: String
        var urlToUpload: URL
        var uploadInfo: UploadInfo
        var taskInfo: TaskInfo?

        init(attachmentId: String, attachmentType: AttachmentType, eventReportId: String, urlToUpload: URL, uploadInfo: UploadInfo) {
            self.attachmentId = attachmentId
            self.attachmentType = attachmentType
            self.eventReportId = eventReportId
            self.urlToUpload = urlToUpload
            self.uploadInfo = uploadInfo
        }
    }
}
