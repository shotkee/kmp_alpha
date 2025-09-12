//
//  RealmInsuranceBillTransformer.swift
//  AlfaStrah
//
//  Created by Vyacheslav Shakaev on 13.12.2021.
//  Copyright © 2021 Touch Instinct. All rights reserved.
//

class RealmInsuranceBillTransformer<T: Entity>: RealmTransformer<T> {
    typealias EntityType = InsuranceBill
    typealias RealmEntityType = RealmInsuranceBill

    override var objectType: RealmEntity.Type {
        RealmEntityType.self
    }

    override func transform(entity: T) throws -> RealmEntity {
        guard let entity = entity as? EntityType else { throw RealmError.typeMismatch }

        let realmEntity = RealmEntityType()
        realmEntity.id = entity.id
        realmEntity.recipientName = entity.recipientName
        realmEntity.number = entity.number
        realmEntity.info = entity.info
        realmEntity.statusText = entity.statusText
        realmEntity.creationDate = entity.creationDate
        realmEntity.moneyAmount = entity.moneyAmount
        realmEntity.billDescription = entity.description
        realmEntity.shouldBePaidOff = entity.shouldBePaidOff
        realmEntity.canBePaidInGroup = entity.canBePaidInGroup
        realmEntity.canSubmitDisagreement = entity.canSubmitDisagreement
        realmEntity.paymentDate = entity.paymentDate
        realmEntity.highlighting = entity.highlighting.rawValue

        return realmEntity
    }

    override func transform(object: RealmEntity) throws -> T {
        guard let object = object as? RealmEntityType else { throw RealmError.typeMismatch }

        let entity = EntityType(
            id: object.id,
            recipientName: object.recipientName,
            number: object.number,
            info: object.info,
            statusText: object.statusText,
            creationDate: object.creationDate,
            moneyAmount: object.moneyAmount,
            description: object.billDescription,
            shouldBePaidOff: object.shouldBePaidOff,
            canBePaidInGroup: object.canBePaidInGroup,
            canSubmitDisagreement: object.canSubmitDisagreement,
            paymentDate: object.paymentDate,
            highlighting: .init(rawValue: object.highlighting) ?? InsuranceBill.Highlighting.noHighlighting
        )
        if let entity = entity as? T {
            return entity
        } else {
            throw RealmError.typeMismatch
        }
    }
}
