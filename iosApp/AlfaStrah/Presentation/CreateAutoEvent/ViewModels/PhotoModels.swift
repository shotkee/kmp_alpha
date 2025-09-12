//
// PhotoModels
// AlfaStrah
//
// Created by Eugene Egorov on 15 January 2019.
// Copyright (c) 2019 Redmadrobot. All rights reserved.
//

enum PhotoGroupType: String {
    case place = "place"
    case plan = "plan"
    case damage = "damage"
    case vin = "vin"
    case docs = "docs"
}

class PhotoGroup {
    var title: String
    var hint: String?
    var type: PhotoGroupType
    var icon: String
    var minPhotos: Int
    var isPhotoLibraryAllowed: Bool
    var steps: [AutoPhotoStep]

    init(title: String, hint: String?, type: PhotoGroupType, icon: String, minPhotos: Int,
           isPhotoLibraryAllowed: Bool, steps: [AutoPhotoStep]) {
        self.title = title
        self.hint = hint
        self.type = type
        self.icon = icon
        self.minPhotos = minPhotos
        self.isPhotoLibraryAllowed = isPhotoLibraryAllowed
        self.steps = steps
    }

    var isReady: Bool {
        totalPhotos >= minPhotos && steps.allSatisfy { $0.isReady }
    }

    var totalPhotos: Int {
        steps.reduce(0) { $0 + $1.attachments.count }
    }

    var photoCountText: String {
        "\(totalPhotos)" + " " + NSLocalizedString("auto_event_photo", comment: "")
    }

    var photos: [Attachment] {
        steps.flatMap { $0.attachments }
    }

    func add(attachments newAttachments: [Attachment], stepId: Int) {
        for step in steps where step.stepId == stepId {
            step.attachments.append(contentsOf: newAttachments)
        }
    }
}

class AutoPhotoStep: BaseDocumentStep {
    var order: Int
    var fileType: AttachmentPhotoType
    var stepId: Int
    var icon: String
    var hint: String

    init(title: String, order: Int, attachmentType: AttachmentPhotoType, stepId: Int, icon: String, minPhotos: Int,
            maxPhotos: Int, hint: String, photos: [PhotoAttachment]) {
        self.order = order
        self.fileType = attachmentType
        self.stepId = stepId
        self.icon = icon
        self.hint = hint

        super.init(title: title, minDocuments: minPhotos, maxDocuments: maxPhotos, attachments: photos)
    }
}
