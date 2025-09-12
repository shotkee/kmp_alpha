//
// RealmCoordinateTransformer
// AlfaStrah
//
// Created by Eugene Egorov on 05 February 2019.
// Copyright (c) 2019 Redmadrobot. All rights reserved.
//

class RealmCoordinateTransformer<T: Entity>: RealmTransformer<T> {
    typealias EntityType = Coordinate
    typealias RealmEntityType = RealmCoordinate

    override var objectType: RealmEntity.Type {
        RealmEntityType.self
    }

    override func transform(entity: T) throws -> RealmEntity {
        guard let entity = entity as? EntityType else { throw RealmError.typeMismatch }

        let realmEntity = RealmEntityType()
        realmEntity.latitude = entity.latitude
        realmEntity.longitude = entity.longitude
        return realmEntity
    }

    override func transform(object: RealmEntity) throws -> T {
        guard let object = object as? RealmEntityType else { throw RealmError.typeMismatch }

        let entity = EntityType(
            latitude: object.latitude,
            longitude: object.longitude
        )
        if let entity = entity as? T {
            return entity
        } else {
            throw RealmError.typeMismatch
        }
    }
}
