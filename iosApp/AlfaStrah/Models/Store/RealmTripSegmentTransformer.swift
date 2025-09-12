//
//  RealmTripSegmentTransformer
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 13/02/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

class RealmTripSegmentTransformer<T: Entity>: RealmTransformer<T> {
    typealias EntityType = TripSegment
    typealias RealmEntityType = RealmTripSegment

    override var objectType: RealmEntity.Type {
        RealmEntityType.self
    }

    override func transform(entity: T) throws -> RealmEntity {
        guard let entity = entity as? EntityType else { throw RealmError.typeMismatch }

        let realmEntity = RealmEntityType()
        realmEntity.number = entity.number
        realmEntity.departure = entity.departure
        realmEntity.arrival = entity.arrival
        return realmEntity
    }

    override func transform(object: RealmEntity) throws -> T {
        guard let object = object as? RealmEntityType else { throw RealmError.typeMismatch }

        let entity = EntityType(
            number: object.number,
            departure: object.departure,
            arrival: object.arrival
        )
        if let entity = entity as? T {
            return entity
        } else {
            throw RealmError.typeMismatch
        }
    }
}
