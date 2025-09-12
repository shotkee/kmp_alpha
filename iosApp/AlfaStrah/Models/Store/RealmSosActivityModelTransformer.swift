//
//  RealmSosActivityModelTransformer.swift
//  AlfaStrah
//
//  Created by Evgeny Ivanov on 11/04/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

class RealmSosActivityModelTransformer<T: Entity>: RealmTransformer<T> {
    typealias EntityType = SosActivityModel
    typealias RealmEntityType = RealmSosActivityModel

    private let sosPhoneTransformer: RealmSosPhoneTransformer<SosPhone> = .init()

    override var objectType: RealmEntity.Type {
        RealmEntityType.self
    }

    override func transform(entity: T) throws -> RealmEntity {
        guard let entity = entity as? EntityType else { throw RealmError.typeMismatch }

        let realmEntity = RealmEntityType()
        realmEntity.title = entity.title
        realmEntity.id = entity.kind.rawValue
        realmEntity.modelDescription = entity.description
        entity.insuranceIdList.forEach { id in
            realmEntity.insuranceIdList.append(id)
        }
        try entity.sosPhoneList.forEach {
            realmEntity.sosPhoneList.append(try sosPhoneTransformer.transform(entity: $0))
        }
        return realmEntity
    }

    override func transform(object: RealmEntity) throws -> T {
        guard let object = object as? RealmEntityType else { throw RealmError.typeMismatch }

        guard let sosActivityKind = SOSActivityKind(rawValue: object.id) else { throw RealmError.typeMismatch }

        let entity = EntityType(
            kind: sosActivityKind,
            title: object.title,
            description: object.modelDescription,
            sosPhoneList: try object.sosPhoneList.map(sosPhoneTransformer.transform(object: )),
            insuranceIdList: Array(object.insuranceIdList)
        )
        if let entity = entity as? T {
            return entity
        } else {
            throw RealmError.typeMismatch
        }
    }
}
