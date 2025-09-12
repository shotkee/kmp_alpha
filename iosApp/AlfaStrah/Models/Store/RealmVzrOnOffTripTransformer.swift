//
//  RealmVzrOnOffTripTransformer.swift
//  AlfaStrah
//
//  Created by Amir Nuriev on 11/14/19.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

class RealmVzrOnOffTripTransformer<T: Entity>: RealmTransformer<T> {
    typealias EntityType = VzrOnOffTrip
    typealias RealmEntityType = RealmVzrOnOffTrip

    override var objectType: RealmEntity.Type {
        RealmEntityType.self
    }

    override func transform(entity: T) throws -> RealmEntity {
        guard let entity = entity as? EntityType else { throw RealmError.typeMismatch }

        let realmEntity = RealmEntityType()
        realmEntity.id = entity.id
        realmEntity.startDate = entity.startDate
        realmEntity.endDate = entity.endDate
        realmEntity.days = entity.days
        realmEntity.status.value = entity.status.rawValue

        return realmEntity
    }

    override func transform(object: RealmEntity) throws -> T {
        guard let object = object as? RealmEntityType else { throw RealmError.typeMismatch }

        guard
            let statusRawValue = object.status.value,
            let status = VzrOnOffTrip.TripStatus(rawValue: statusRawValue)
        else { throw RealmError.typeMismatch }

        let entity = EntityType(
            id: object.id,
            startDate: object.startDate,
            endDate: object.endDate,
            days: object.days,
            status: status
        )

        if let entity = entity as? T {
            return entity
        } else {
            throw RealmError.typeMismatch
        }
    }
}
