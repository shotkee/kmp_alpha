//
//  RealmAttachmentEventLogTransformer
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 28.11.2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

class RealmAttachmentEventLogTransformer<T: Entity>: RealmTransformer<T> {
    typealias EntityType = AttachmentEventLog
    typealias RealmEntityType = RealmAttachmentEventLog

    override var objectType: RealmEntity.Type {
        RealmEntityType.self
    }

    override func transform(entity: T) throws -> RealmEntity {
        guard let entity = entity as? EntityType else { throw RealmError.typeMismatch }

        let realmEntity = RealmEntityType()
        realmEntity.eventReportId = entity.eventReportId
        realmEntity.message = entity.message
        realmEntity.closed = entity.closed
        return realmEntity
    }

    override func transform(object: RealmEntity) throws -> T {
        guard let object = object as? RealmEntityType else { throw RealmError.typeMismatch }

        let entity = EntityType(
            eventReportId: object.eventReportId,
            message: object.message,
            closed: object.closed
        )

        if let entity = entity as? T {
            return entity
        } else {
            throw RealmError.typeMismatch
        }
    }
}
