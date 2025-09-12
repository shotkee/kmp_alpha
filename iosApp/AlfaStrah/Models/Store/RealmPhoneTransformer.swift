//
// RealmPhoneTransformer
// AlfaStrah
//
// Created by Eugene Egorov on 05 February 2019.
// Copyright (c) 2019 Redmadrobot. All rights reserved.
//

class RealmPhoneTransformer<T: Entity>: RealmTransformer<T> {
    typealias EntityType = Phone
    typealias RealmEntityType = RealmPhone
    
    private let voipCallTransformer: RealmVoipCallTransformer<VoipCall> = .init()

    override var objectType: RealmEntity.Type {
        RealmEntityType.self
    }

    override func transform(entity: T) throws -> RealmEntity {
        guard let entity = entity as? EntityType else { throw RealmError.typeMismatch }

        let realmEntity = RealmEntityType()
        realmEntity.plain = entity.plain
        realmEntity.humanReadable = entity.humanReadable
        realmEntity.voipCall = try entity.voipCall.map(voipCallTransformer.transform(entity:))
        return realmEntity
    }

    override func transform(object: RealmEntity) throws -> T {
        guard let object = object as? RealmEntityType else { throw RealmError.typeMismatch }

        let entity = EntityType(
            plain: object.plain,
            humanReadable: object.humanReadable,
            voipCall: try object.voipCall.map(voipCallTransformer.transform(object:))
        )
        if let entity = entity as? T {
            return entity
        } else {
            throw RealmError.typeMismatch
        }
    }
}
