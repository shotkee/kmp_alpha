//
//  RealmLoyaltyModelTransformer.swift
//  AlfaStrah
//
//  Created by Evgeny Ivanov on 28/04/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

class RealmLoyaltyModelTransformer<T: Entity>: RealmTransformer<T> {
    typealias EntityType = LoyaltyModel
    typealias RealmEntityType = RealmLoyaltyModel

    private let operationTransformer: RealmLoyaltyOperationTransformer<LoyaltyOperation> = .init()
    private let deepLinkTransformer: RealmInsuranceDeeplinkTypeTransformer<InsuranceDeeplinkType> = .init()
    private let phoneTransformer: RealmPhoneTransformer<Phone> = .init()

    override var objectType: RealmEntity.Type {
        RealmEntityType.self
    }

    override func transform(entity: T) throws -> RealmEntity {
        guard let entity = entity as? EntityType else { throw RealmError.typeMismatch }

        let realmEntity = RealmEntityType()
        realmEntity.amount = entity.amount
        realmEntity.added = entity.added
        realmEntity.spent = entity.spent
        realmEntity.status = entity.status
        realmEntity.statusDescription = entity.statusDescription
        realmEntity.nextStatus = entity.nextStatus
        realmEntity.nextStatusMoney = entity.nextStatusMoney
        realmEntity.nextStatusDescription = entity.nextStatusDescription
        realmEntity.hotlineDescription = entity.hotlineDescription
        realmEntity.hotlinePhone = try entity.hotlinePhone.map(phoneTransformer.transform(entity:))
        try (entity.lastOperations).forEach {
            realmEntity.lastOperations.append(try operationTransformer.transform(entity: $0))
        }
        try (entity.insuranceDeeplinkTypes).forEach {
            realmEntity.insuranceDeeplinkTypes.append(try deepLinkTransformer.transform(entity: $0))
        }
        realmEntity.operationsCnt = entity.operationsCnt
        return realmEntity
    }

    override func transform(object: RealmEntity) throws -> T {
        guard let object = object as? RealmEntityType else { throw RealmError.typeMismatch }

        let entity = EntityType(
            amount: object.amount,
            added: object.added,
            spent: object.spent,
            status: object.status,
            statusDescription: object.statusDescription,
            nextStatus: object.nextStatus,
            nextStatusMoney: object.nextStatusMoney,
            nextStatusDescription: object.nextStatusDescription,
            hotlineDescription: object.hotlineDescription,
            hotlinePhone: try object.hotlinePhone.map(phoneTransformer.transform(object:)),
            lastOperations: try object.lastOperations.map(operationTransformer.transform(object:)),
            insuranceDeeplinkTypes: try object.insuranceDeeplinkTypes.map(deepLinkTransformer.transform(object:)),
            operationsCnt: object.operationsCnt
        )
        if let entity = entity as? T {
            return entity
        } else {
            throw RealmError.typeMismatch
        }
    }
}
