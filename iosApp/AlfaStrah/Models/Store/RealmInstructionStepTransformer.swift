//
//  RealmInstructionStepTransformer.swift
//  AlfaStrah
//
//  Created by Evgeny Ivanov on 12/04/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

class RealmInstructionStepTransformer<T: Entity>: RealmTransformer<T> {
    typealias EntityType = InstructionStep
    typealias RealmEntityType = RealmInstructionStep

    override var objectType: RealmEntity.Type {
        RealmEntityType.self
    }

    override func transform(entity: T) throws -> RealmEntity {
        guard let entity = entity as? EntityType else { throw RealmError.typeMismatch }

        let realmEntity = RealmEntityType()
        realmEntity.fullDescription = entity.fullDescription
        realmEntity.sortNumber = entity.sortNumber
        realmEntity.title = entity.title
        return realmEntity
    }

    override func transform(object: RealmEntity) throws -> T {
        guard let object = object as? RealmEntityType else { throw RealmError.typeMismatch }

        let entity = EntityType(
            sortNumber: object.sortNumber,
            title: object.title,
            fullDescription: object.fullDescription
        )
        if let entity = entity as? T {
            return entity
        } else {
            throw RealmError.typeMismatch
        }
    }
}
