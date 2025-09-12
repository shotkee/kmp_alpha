//
//  RealmInstructionTransformer.swift
//  AlfaStrah
//
//  Created by Evgeny Ivanov on 12/04/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

class RealmInstructionTransformer<T: Entity>: RealmTransformer<T> {
    typealias EntityType = Instruction
    typealias RealmEntityType = RealmInstruction

    private let stepTransformer: RealmInstructionStepTransformer<InstructionStep> = .init()

    override var objectType: RealmEntity.Type {
        RealmEntityType.self
    }

    override func transform(entity: T) throws -> RealmEntity {
        guard let entity = entity as? EntityType else { throw RealmError.typeMismatch }

        let realmEntity = RealmEntityType()
        realmEntity.id = entity.id
        realmEntity.title = entity.title
        realmEntity.insuranceCategoryId = entity.insuranceCategoryId
        realmEntity.fullDescription = entity.fullDescription
        realmEntity.lastModified = entity.lastModified
        realmEntity.shortDescription = entity.shortDescription
        try entity.steps.forEach {
            realmEntity.steps.append(try stepTransformer.transform(entity: $0))
        }
        return realmEntity
    }

    override func transform(object: RealmEntity) throws -> T {
        guard let object = object as? RealmEntityType else { throw RealmError.typeMismatch }

        let entity = EntityType(
            id: object.id,
            insuranceCategoryId: object.insuranceCategoryId,
            lastModified: object.lastModified,
            title: object.title,
            shortDescription: object.shortDescription,
            fullDescription: object.fullDescription,
            steps: try object.steps.map(stepTransformer.transform(object: ))
        )
        if let entity = entity as? T {
            return entity
        } else {
            throw RealmError.typeMismatch
        }
    }
}
