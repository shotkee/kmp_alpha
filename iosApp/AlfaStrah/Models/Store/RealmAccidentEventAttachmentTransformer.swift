//
//  RealmAccidentEventAttachmentTransformer
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 18.11.2020.
//  Copyright © 2020 Redmadrobot. All rights reserved.
//

class RealmAccidentEventAttachmentTransformer<T: Entity>: RealmTransformer<T> {
    typealias EntityType = AccidentEventAttachment
    typealias RealmEntityType = RealmAccidentEventAttachment

    override var objectType: RealmEntity.Type {
        RealmEntityType.self
    }

    override func transform(entity: T) throws -> RealmEntity {
        guard let entity = entity as? EntityType else { throw RealmError.typeMismatch }

        let realmEntity = RealmEntityType()
        realmEntity.id = entity.id
        realmEntity.eventReportId = entity.eventReportId
        realmEntity.filename = entity.filename
        return realmEntity
    }

    override func transform(object: RealmEntity) throws -> T {
        guard let object = object as? RealmEntityType else { throw RealmError.typeMismatch }

        let entity = EntityType(
            id: object.id,
            eventReportId: object.eventReportId,
            filename: object.filename
        )
        if let entity = entity as? T {
            return entity
        } else {
            throw RealmError.typeMismatch
        }
    }
}
