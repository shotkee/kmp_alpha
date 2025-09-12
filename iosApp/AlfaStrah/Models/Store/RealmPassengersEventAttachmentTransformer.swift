//
//  RealmPassengersEventAttachmentTransformer
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 21/06/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

class RealmPassengersEventAttachmentTransformer<T: Entity>: RealmTransformer<T> {
    typealias EntityType = PassengersEventAttachment
    typealias RealmEntityType = RealmPassengersEventAttachment

    override var objectType: RealmEntity.Type {
        RealmEntityType.self
    }

    override func transform(entity: T) throws -> RealmEntity {
        guard let entity = entity as? EntityType else { throw RealmError.typeMismatch }

        let realmEntity = RealmEntityType()
        realmEntity.id = entity.id
        realmEntity.eventReportId = entity.eventReportId
        realmEntity.documentId = entity.documentId
        realmEntity.filename = entity.filename
        realmEntity.documentsCount = entity.documentsCount
        return realmEntity
    }

    override func transform(object: RealmEntity) throws -> T {
        guard let object = object as? RealmEntityType else { throw RealmError.typeMismatch }

        let entity = EntityType(
            id: object.id,
            eventReportId: object.eventReportId,
            documentId: object.documentId,
            filename: object.filename,
            documentsCount: object.documentsCount
        )

        if let entity = entity as? T {
            return entity
        } else {
            throw RealmError.typeMismatch
        }
    }
}
