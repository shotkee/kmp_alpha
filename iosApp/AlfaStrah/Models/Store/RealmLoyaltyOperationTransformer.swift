//
//  RealmLoyaltyOperationTransformer.swift
//  AlfaStrah
//
//  Created by Evgeny Ivanov on 27/04/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import Realm
import RealmSwift

class RealmLoyaltyOperationTransformer<T: Entity>: RealmTransformer<T> {
    typealias EntityType = LoyaltyOperation
    typealias RealmEntityType = RealmLoyaltyOperation

    override var objectType: RealmEntity.Type {
        RealmEntityType.self
    }

    override func transform(entity: T) throws -> RealmEntity {
        guard let entity = entity as? EntityType else { throw RealmError.typeMismatch }

        let realmEntity = RealmEntityType()
        realmEntity.id = entity.id
        realmEntity.productId = entity.productId
        realmEntity.categoryId = entity.categoryId
        realmEntity.categoryType.value = entity.categoryType
        realmEntity.insuranceDeeplinkTypeId.value = entity.insuranceDeeplinkTypeId
        realmEntity.loyaltyType.value = entity.loyaltyType.map { $0.rawValue }
        realmEntity.operationType.value = entity.operationType.map { $0.rawValue }
        realmEntity.amount = entity.amount
        realmEntity.modelDescription = entity.description
        realmEntity.date = entity.date
        realmEntity.status.value = entity.status?.rawValue
        realmEntity.statusDescription = entity.statusDescription
        realmEntity.contractNumber = entity.contractNumber
        realmEntity.iconType.value = entity.iconType.map { $0.rawValue }

        return realmEntity
    }

    override func transform(object: RealmEntity) throws -> T {
        guard let object = object as? RealmEntityType else { throw RealmError.typeMismatch }

        guard let operationTypeRawValue = object.operationType.value,
            let operationType = LoyaltyOperation.OperationType(rawValue: operationTypeRawValue)
        else { throw RealmError.typeMismatch }

        let entity = EntityType(
            id: object.id,
            productId: object.productId,
            categoryId: object.categoryId,
            categoryType: object.categoryType.value,
            insuranceDeeplinkTypeId: object.insuranceDeeplinkTypeId.value,
            loyaltyType: object.loyaltyType.value.flatMap(LoyaltyOperation.LoyaltyType.init),
            operationType: operationType,
            amount: object.amount,
            description: object.modelDescription,
            date: object.date,
            statusDescription: object.statusDescription,
            status: object.status.value.flatMap { LoyaltyOperation.OperationStatus(rawValue: $0) },
            contractNumber: object.contractNumber,
            iconType: object.iconType.value.flatMap(LoyaltyOperation.IconType.init)
        )

        if let entity = entity as? T {
            return entity
        } else {
            throw RealmError.typeMismatch
        }
    }
}
