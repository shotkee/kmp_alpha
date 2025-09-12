//
//  RealmSosEmergencyCommunicationBlockTransformer.swift
//  AlfaStrah
//
//  Created by Makson on 09.11.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

import Foundation

class RealmSosEmergencyCommunicationBlockTransformer<T: Entity>: RealmTransformer<T> {
    typealias EntityType = SosEmergencyCommunicationBlock
    typealias RealmEntityType = RealmSosEmergencyCommunicationBlock
    
    private let sosEmergencyCommunicationItemTransformer: RealmSosEmergencyCommunicationItemTransformer<SosEmergencyCommunicationItem> = .init()
    
    override var objectType: RealmEntity.Type {
        RealmEntityType.self
    }

    override func transform(entity: T) throws -> RealmEntity {
        guard let entity = entity as? EntityType else { throw RealmError.typeMismatch }

        let realmEntity = RealmEntityType()
        realmEntity.title = entity.title
        try entity.itemList.forEach {
            realmEntity.itemList.append(try sosEmergencyCommunicationItemTransformer.transform(entity: $0))
        }
        
        return realmEntity
    }

    override func transform(object: RealmEntity) throws -> T {
        guard let object = object as? RealmEntityType
        else { throw RealmError.typeMismatch }

        let entity = EntityType(
            title: object.title,
            itemList: try object.itemList.map(
                sosEmergencyCommunicationItemTransformer.transform(object: )
            )
        )
        
        if let entity = entity as? T {
            return entity
        } else {
            throw RealmError.typeMismatch
        }
    }
}
