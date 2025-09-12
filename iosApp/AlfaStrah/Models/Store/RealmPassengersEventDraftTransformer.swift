//
//  RealmPassengersEventDraftTransformer
//  AlfaStrah
//
//  Created by Evgeny Ivanov on 04/06/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

class RealmPassengersEventDraftTransformer<T: Entity>: RealmTransformer<T> {
    typealias EntityType = PassengersEventDraft
    typealias RealmEntityType = RealmPassengersEventDraft

    private let riskValueTransformer: RealmRiskValueTransformer<RiskValue> = .init()

    override var objectType: RealmEntity.Type {
        RealmEntityType.self
    }

    override func transform(entity: T) throws -> RealmEntity {
        guard let entity = entity as? EntityType else { throw RealmError.typeMismatch }

        let realmEntity = RealmEntityType()
        realmEntity.id = entity.id
        realmEntity.riskId = entity.riskId
        realmEntity.insuranceId = entity.insuranceId
        realmEntity.date = entity.date
        try (entity.values).forEach {
            realmEntity.values.append(try riskValueTransformer.transform(entity: $0))
        }
        return realmEntity
    }

    override func transform(object: RealmEntity) throws -> T {
        guard let object = object as? RealmEntityType else { throw RealmError.typeMismatch }

        let entity = EntityType(
            id: object.id,
            insuranceId: object.insuranceId,
            riskId: object.riskId,
            date: object.date,
            values: try object.values.map(riskValueTransformer.transform(object:))
        )
        if let entity = entity as? T {
            return entity
        } else {
            throw RealmError.typeMismatch
        }
    }
}
