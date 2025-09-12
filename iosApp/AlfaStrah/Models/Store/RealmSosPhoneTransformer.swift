//
//  RealmSosPhoneTransformer.swift
//  AlfaStrah
//
//  Created by Evgeny Ivanov on 11/04/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

class RealmSosPhoneTransformer<T: Entity>: RealmTransformer<T> {
    typealias EntityType = SosPhone
    typealias RealmEntityType = RealmSosPhone
    
    private let voipCallTransformer: RealmVoipCallTransformer<VoipCall> = .init()

    override var objectType: RealmEntity.Type {
        RealmEntityType.self
    }

    override func transform(entity: T) throws -> RealmEntity {
        guard let entity = entity as? EntityType else { throw RealmError.typeMismatch }

        let realmEntity = RealmEntityType()
        realmEntity.title = entity.title
        realmEntity.modelDecription = entity.description
        realmEntity.phone = entity.phone
        realmEntity.voipCall = try entity.voipCall.map(voipCallTransformer.transform(entity:))
        return realmEntity
    }

    override func transform(object: RealmEntity) throws -> T {
        guard let object = object as? RealmEntityType else { throw RealmError.typeMismatch }

        let entity = EntityType(
            title: object.title,
            description: object.modelDecription,
            phone: object.phone,
            voipCall: try object.voipCall.map(voipCallTransformer.transform(object:))
        )

        if let entity = entity as? T {
            return entity
        } else {
            throw RealmError.typeMismatch
        }
    }
}
