//
// RealmAppNotificationFieldTransformer
// AlfaStrah
//
// Created by Eugene Egorov on 05 February 2019.
// Copyright (c) 2019 Redmadrobot. All rights reserved.
//

class RealmAppNotificationFieldTransformer<T: Entity>: RealmTransformer<T> {
    typealias EntityType = AppNotificationField
    typealias RealmEntityType = RealmAppNotificationField

    override var objectType: RealmEntity.Type {
        RealmEntityType.self
    }

    override func transform(entity: T) throws -> RealmEntity {
        guard let entity = entity as? EntityType else { throw RealmError.typeMismatch }

        let realmEntity = RealmEntityType()
        realmEntity.title = entity.title
        realmEntity.value = entity.value
        return realmEntity
    }

    override func transform(object: RealmEntity) throws -> T {
        guard let object = object as? RealmEntityType else { throw RealmError.typeMismatch }

        let entity = EntityType(
            title: object.title,
            value: object.value
        )
        if let entity = entity as? T {
            return entity
        } else {
            throw RealmError.typeMismatch
        }
    }
}
