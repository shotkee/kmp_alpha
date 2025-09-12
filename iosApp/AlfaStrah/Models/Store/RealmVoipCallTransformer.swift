//
//  RealmVoipCallTransformer.swift
//  AlfaStrah
//
//  Created by vit on 12.12.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

import Foundation

class RealmVoipCallTransformer<T: Entity>: RealmTransformer<T> {
    typealias EntityType = VoipCall
    typealias RealmEntityType = RealmVoipCall
    
    override var objectType: RealmEntity.Type {
        RealmEntityType.self
    }

    override func transform(entity: T) throws -> RealmEntity {
        guard let entity = entity as? EntityType
        else { throw RealmError.typeMismatch }

        let realmEntity = RealmEntityType()
        realmEntity.title = entity.title
        realmEntity.internalType = entity.internalType.rawValue
        realmEntity.parameters = try? JSONSerialization.data(withJSONObject: entity.parameters)

        return realmEntity
    }

    override func transform(object: RealmEntity) throws -> T {
        guard let object = object as? RealmEntityType,
              let internalType = VoipCall.InternalCallType(rawValue: object.internalType)
        else { throw RealmError.typeMismatch }
        
        let entity = EntityType(
            title: object.title,
            internalType: internalType,
            parameters: {
                guard let parametersData = object.parameters
                else { return nil }
                
                return try? JSONSerialization.jsonObject(with: parametersData) as? [String: Any]
            }()
        )
        
        if let entity = entity as? T {
            return entity
        } else {
            throw RealmError.typeMismatch
        }
    }
}
