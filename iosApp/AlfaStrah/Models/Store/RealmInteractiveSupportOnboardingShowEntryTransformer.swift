//
//  RealmInteractiveSupportOnboardingShowEntryTransformer.swift
//  AlfaStrah
//
//  Created by vit on 28.11.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

// swiftlint:disable:next type_name
class RealmInteractiveSupportOnboardingShowEntryTransformer<T: Entity>: RealmTransformer<T> {
    typealias EntityType = InteractiveSupportOnboardingShowEntry
    typealias RealmEntityType = RealmInteractiveSupportOnboardingShowEntry
        
    override var objectType: RealmEntity.Type {
        RealmEntityType.self
    }

    override func transform(entity: T) throws -> RealmEntity {
        guard let entity = entity as? EntityType
        else { throw RealmError.typeMismatch }

        let realmEntity = RealmEntityType()
        
        realmEntity.insuranceId = entity.insuranceId
        
        return realmEntity
    }

    override func transform(object: RealmEntity) throws -> T {
        guard let object = object as? RealmEntityType
        else { throw RealmError.typeMismatch }

        let entity = EntityType(insuranceId: object.insuranceId)
        
        if let entity = entity as? T {
            return entity
        } else {
            throw RealmError.typeMismatch
        }
    }
}
