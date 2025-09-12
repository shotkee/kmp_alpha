//
//  RealmAttachmentsUploadStatusTransformer
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 30.12.2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

class RealmAttachmentsUploadStatusTransformer<T: Entity>: RealmTransformer<T> {
    typealias EntityType = AttachmentsUploadStatus
    typealias RealmEntityType = RealmAttachmentsUploadStatus

    override var objectType: RealmEntity.Type {
        RealmEntityType.self
    }

    override func transform(entity: T) throws -> RealmEntity {
        guard let entity = entity as? EntityType else { throw RealmError.typeMismatch }

        let realmEntity = RealmEntityType()
        realmEntity.eventReportId = entity.eventReportId
        realmEntity.totalDocumentsCount = entity.totalDocumentsCount
        realmEntity.uploadedDocumentsCount = entity.uploadedDocumentsCount
        return realmEntity
    }

    override func transform(object: RealmEntity) throws -> T {
        guard let object = object as? RealmEntityType else { throw RealmError.typeMismatch }

        let entity = EntityType(
            eventReportId: object.eventReportId,
            totalDocumentsCount: object.totalDocumentsCount,
            uploadedDocumentsCount: object.uploadedDocumentsCount
        )
        if let entity = entity as? T {
            return entity
        } else {
            throw RealmError.typeMismatch
        }
    }
}
