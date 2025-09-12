//
//  RealmSosInsuranceTypeTransformer.swift
//  AlfaStrah
//
//  Created by Makson on 28.11.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

import Foundation

class RealmSosInsuranceTypeTransformer<T: Entity>: RealmTransformer<T> {
    typealias EntityType = InsuranceType
    typealias RealmEntityType = RealmInsuranceType
    
    private let phoneTransformer: RealmPhoneTransformer<Phone> = .init()
    private let voipCallTransformer: RealmPhoneTransformer<VoipCall> = .init()

    override var objectType: RealmEntity.Type {
        RealmEntityType.self
    }

    override func transform(entity: T) throws -> RealmEntity {
        guard let entity = entity as? EntityType
        else { throw RealmError.typeMismatch }

        let realmEntity = RealmEntityType()
        realmEntity.title = entity.title
        try entity.phones.forEach {
            realmEntity.phones.append(try phoneTransformer.transform(entity: $0))
        }
        try entity.voipCalls.forEach {
            realmEntity.voipCalls.append(try voipCallTransformer.transform(entity: $0))
        }
        
        return realmEntity
    }

    override func transform(object: RealmEntity) throws -> T {
        guard let object = object as? RealmEntityType
        else { throw RealmError.typeMismatch }

        let entity = EntityType(
            title: object.title,
            phones: try object.phones.map(phoneTransformer.transform(object:)),
            voipCalls: try object.voipCalls.map(voipCallTransformer.transform(object:))
        )
        
        if let entity = entity as? T {
            return entity
        } else {
            throw RealmError.typeMismatch
        }
    }
}
