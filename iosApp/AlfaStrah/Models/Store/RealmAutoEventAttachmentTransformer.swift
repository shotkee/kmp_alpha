//
//  RealmAutoEventAttachmentTransformer
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 18/06/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

class RealmAutoEventAttachmentTransformer<T: Entity>: RealmTransformer<T> {
    typealias EntityType = AutoEventAttachment
    typealias RealmEntityType = RealmAutoEventAttachment

    override var objectType: RealmEntity.Type {
        RealmEntityType.self
    }

    override func transform(entity: T) throws -> RealmEntity {
        guard let entity = entity as? EntityType else { throw RealmError.typeMismatch }

        let realmEntity = RealmEntityType()
        realmEntity.id = entity.id
        realmEntity.eventReportId = entity.eventReportId
        realmEntity.filename = entity.filename
        realmEntity.fileType = entity.fileType.rawValue
        realmEntity.isOptional = entity.isOptional
        return realmEntity
    }

    override func transform(object: RealmEntity) throws -> T {
        guard let object = object as? RealmEntityType else { throw RealmError.typeMismatch }
        guard let fileType = AttachmentPhotoType(rawValue: object.fileType) else { throw RealmError.typeMismatch }

        let entity = EntityType(
            id: object.id,
            eventReportId: object.eventReportId,
            filename: object.filename,
            fileType: fileType,
            isOptional: object.isOptional
        )
        if let entity = entity as? T {
            return entity
        } else {
            throw RealmError.typeMismatch
        }
    }
}
