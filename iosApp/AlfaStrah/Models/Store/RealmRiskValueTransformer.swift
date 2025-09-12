//
//  RealmRiskValue.swift
//  AlfaStrah
//
//  Created by Evgeny Ivanov on 04/06/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

class RealmRiskValueTransformer<T: Entity>: RealmTransformer<T> {
    typealias EntityType = RiskValue
    typealias RealmEntityType = RealmRiskValue

    override var objectType: RealmEntity.Type {
        RealmEntityType.self
    }

    override func transform(entity: T) throws -> RealmEntity {
        guard let entity = entity as? EntityType else { throw RealmError.typeMismatch }

        let realmEntity = RealmEntityType()
        realmEntity.categoryId = entity.categoryId
        realmEntity.dataId = entity.dataId
        realmEntity.riskId = entity.riskId
        realmEntity.value = entity.value
        realmEntity.optionId = entity.optionId
        return realmEntity
    }

    override func transform(object: RealmEntity) throws -> T {
        guard let object = object as? RealmEntityType else { throw RealmError.typeMismatch }

        let entity = EntityType(
            riskId: object.riskId,
            categoryId: object.categoryId,
            dataId: object.dataId,
            optionId: object.optionId,
            value: object.value
        )
        if let entity = entity as? T {
            return entity
        } else {
            throw RealmError.typeMismatch
        }
    }
}
