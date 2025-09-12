//
//  RealmAnonymousSosTransformer.swift
//  AlfaStrah
//
//  Created by Makson on 30.11.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

class RealmAnonymousSosTransformer<T: Entity>: RealmTransformer<T> {
    typealias EntityType = AnonymousSos
    typealias RealmEntityType = RealmAnonymousSos

    private let sosModelTransformer: RealmSosModelTransformer<SosModel> = .init()
    private let sosEmergencyCommunicationTransformer: RealmSosEmergencyCommunicationTransformer<SosEmergencyCommunication> = .init()
    
    override var objectType: RealmEntity.Type {
        RealmEntityType.self
    }

    override func transform(entity: T) throws -> RealmEntity {
        guard let entity = entity as? EntityType else { throw RealmError.typeMismatch }

        let realmEntity = RealmEntityType()

        try entity.sosList.forEach {
            realmEntity.sosList.append(try sosModelTransformer.transform(entity: $0))
        }
        realmEntity.sosEmergencyCommunication = try entity.sosEmergencyCommunication.map(
            sosEmergencyCommunicationTransformer.transform(entity:)
        )
        
        return realmEntity
    }

    override func transform(object: RealmEntity) throws -> T {
        guard let object = object as? RealmEntityType
        else { throw RealmError.typeMismatch }

        let entity = EntityType(
            sosList: try object.sosList.map(
                sosModelTransformer.transform(object: )
            ),
            sosEmergencyCommunication: try object.sosEmergencyCommunication.map(sosEmergencyCommunicationTransformer.transform(object:))
        )
        if let entity = entity as? T {
            return entity
        } else {
            throw RealmError.typeMismatch
        }
    }
}
