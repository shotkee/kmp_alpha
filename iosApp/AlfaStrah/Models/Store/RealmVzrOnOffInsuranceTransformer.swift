//
//  RealmVzrOnOffInsuranceTransformer.swift
//  AlfaStrah
//
//  Created by Amir Nuriev on 11/14/19.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

class RealmVzrOnOffInsuranceTransformer<T: Entity>: RealmTransformer<T> {
    typealias EntityType = VzrOnOffInsurance
    typealias RealmEntityType = RealmVzrOnOffInsurance

    private let activeTripTransformer: RealmVzrOnOffTripTransformer<VzrOnOffTrip> = .init()

    override var objectType: RealmEntity.Type {
        RealmEntityType.self
    }

    override func transform(entity: T) throws -> RealmEntity {
        guard let entity = entity as? EntityType else { throw RealmError.typeMismatch }

        let realmEntity = RealmEntityType()
        realmEntity.insuranceId = entity.insuranceId
        try entity.activeTripList.forEach {
            realmEntity.activeTripList.append(try activeTripTransformer.transform(entity: $0))
        }
        return realmEntity
    }

    override func transform(object: RealmEntity) throws -> T {
        guard let object = object as? RealmEntityType else { throw RealmError.typeMismatch }

        guard !object.insuranceId.isEmpty else { throw RealmError.typeMismatch }

        var activeTripList: [VzrOnOffTrip] = []
        try object.activeTripList.forEach {
            guard
                let statusRawValue = $0.status.value,
                let status = VzrOnOffTrip.TripStatus(rawValue: statusRawValue)
            else { throw RealmError.typeMismatch }

            let trip = VzrOnOffTrip(id: $0.id, startDate: $0.startDate, endDate: $0.endDate, days: $0.days, status: status)
            activeTripList.append(trip)
        }
        let entity = EntityType(insuranceId: object.insuranceId, activeTripList: activeTripList)

        if let entity = entity as? T {
            return entity
        } else {
            throw RealmError.typeMismatch
        }
    }
}
