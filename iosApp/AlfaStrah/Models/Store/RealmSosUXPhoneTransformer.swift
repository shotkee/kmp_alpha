//
//  RealmSosUXPhoneTransformer.swift
//  AlfaStrah
//
//  Created by Makson on 09.11.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

import Foundation

class RealmSosUXPhoneTransformer<T: Entity>: RealmTransformer<T> {
    typealias EntityType = SosUXPhone
    typealias RealmEntityType = RealmSosUXPhone
    
    override var objectType: RealmEntity.Type {
        RealmEntityType.self
    }

    override func transform(entity: T) throws -> RealmEntity {
        guard let entity = entity as? EntityType else { throw RealmError.typeMismatch }

        let realmEntity = RealmEntityType()
        realmEntity.phoneNumber = entity.phoneNumber
        return realmEntity
    }

    override func transform(object: RealmEntity) throws -> T {
        guard let object = object as? RealmEntityType else { throw RealmError.typeMismatch }

        let entity = EntityType(
            phoneNumber: object.phoneNumber
        )
        
        if let entity = entity as? T {
            return entity
        } else {
            throw RealmError.typeMismatch
        }
    }
}
