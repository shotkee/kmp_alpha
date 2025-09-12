//
//  RealmAttachmentSavingFailureLogTransformer.swift
//  AlfaStrah
//
//  Created by Amir Nuriev on 23.03.2020.
//  Copyright © 2020 Redmadrobot. All rights reserved.
//

class RealmAttachmentSavingFailureLogTransformer<T: Entity>: RealmTransformer<T> {
    typealias EntityType = AttachmentSavingFailureLog
    typealias RealmEntityType = RealmAttachmentSavingFailureLog

    override var objectType: RealmEntity.Type {
        RealmEntityType.self
    }

    override func transform(entity: T) throws -> RealmEntity {
        guard let entity = entity as? EntityType else { throw RealmError.typeMismatch }

        let realmEntity = RealmEntityType()
        realmEntity.message = entity.message
        return realmEntity
    }

    override func transform(object: RealmEntity) throws -> T {
        guard let object = object as? RealmEntityType else { throw RealmError.typeMismatch }

        let entity = EntityType(
            message: object.message
        )

        if let entity = entity as? T {
            return entity
        } else {
            throw RealmError.typeMismatch
        }
    }
}
