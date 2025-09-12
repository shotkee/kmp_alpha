//
//  RealmInsuranceDeeplinkTypeTransformer.swift
//  AlfaStrah
//
//  Created by Evgeny Ivanov on 27/04/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

class RealmInsuranceDeeplinkTypeTransformer<T: Entity>: RealmTransformer<T> {
    typealias EntityType = InsuranceDeeplinkType
    typealias RealmEntityType = RealmInsuranceDeeplinkType

    override var objectType: RealmEntity.Type {
        RealmEntityType.self
    }

    override func transform(entity: T) throws -> RealmEntity {
        guard let entity = entity as? EntityType else { throw RealmError.typeMismatch }

        let realmEntity = RealmEntityType()
        realmEntity.id = entity.id
        realmEntity.title = entity.title
        realmEntity.categoryId = entity.categoryId
        return realmEntity
    }

    override func transform(object: RealmEntity) throws -> T {
        guard let object = object as? RealmEntityType else { throw RealmError.typeMismatch }

        let entity = EntityType(
            id: object.id,
            title: object.title,
            categoryId: object.categoryId
        )
        if let entity = entity as? T {
            return entity
        } else {
            throw RealmError.typeMismatch
        }
    }
}
