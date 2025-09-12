//
//  RealmInsuranceGroupTransformer.swift
//  AlfaStrah
//
//  Created by Evgeny Ivanov on 11/04/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

class RealmInsuranceGroupTransformer<T: Entity>: RealmTransformer<T> {
    typealias EntityType = InsuranceGroup
    typealias RealmEntityType = RealmInsuranceGroup

    private let insuranceGroupCategoryTransformer: RealmInsuranceGroupCategoryTransformer<InsuranceGroupCategory> = .init()

    override var objectType: RealmEntity.Type {
        RealmEntityType.self
    }

    override func transform(entity: T) throws -> RealmEntity {
        guard let entity = entity as? EntityType else { throw RealmError.typeMismatch }

        let realmEntity = RealmEntityType()
        realmEntity.objectName = entity.objectName
        realmEntity.objectType = entity.objectType
        try entity.insuranceGroupCategoryList.forEach {
            realmEntity.insuranceGroupCategoryList.append(try insuranceGroupCategoryTransformer.transform(entity: $0))
        }
        return realmEntity
    }

    override func transform(object: RealmEntity) throws -> T {
        guard let object = object as? RealmEntityType else { throw RealmError.typeMismatch }

        let entity = EntityType(
            objectName: object.objectName,
            objectType: object.objectType,
            insuranceGroupCategoryList: try object.insuranceGroupCategoryList.map(insuranceGroupCategoryTransformer.transform(object: ))
        )
        if let entity = entity as? T {
            return entity
        } else {
            throw RealmError.typeMismatch
        }
    }
}
