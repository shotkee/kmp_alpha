//
// RealmStoaTransformer
// AlfaStrah
//
// Created by Eugene Egorov on 05 February 2019.
// Copyright (c) 2019 Redmadrobot. All rights reserved.
//

import RealmSwift

class RealmStoaTransformer<T: Entity>: RealmTransformer<T> {
    typealias EntityType = Stoa
    typealias RealmEntityType = RealmStoa

    private let coordinateTransformer: RealmCoordinateTransformer<Coordinate> = .init()
    private let phoneTransformer: RealmPhoneTransformer<Phone> = .init()

    override var objectType: RealmEntity.Type {
        RealmEntityType.self
    }

    override func transform(entity: T) throws -> RealmEntity {
        guard let entity = entity as? EntityType else { throw RealmError.typeMismatch }

        let realmEntity = RealmEntityType()
        realmEntity.id = entity.id
        realmEntity.title = entity.title
        realmEntity.address = entity.address
        realmEntity.coordinate = try coordinateTransformer.transform(entity: entity.coordinate)
        realmEntity.serviceHours = entity.serviceHours
        realmEntity.dealer = entity.dealer
        try entity.phoneList.forEach {
            realmEntity.phoneList.append(try phoneTransformer.transform(entity: $0))
        }
        return realmEntity
    }

    override func transform(object: RealmEntity) throws -> T {
        guard let object = object as? RealmEntityType else { throw RealmError.typeMismatch }

        guard let coordinate = object.coordinate else { throw RealmError.typeMismatch }

        let entity = EntityType(
            id: object.id,
            title: object.title,
            address: object.address,
            coordinate: try coordinateTransformer.transform(object: coordinate),
            serviceHours: object.serviceHours,
            dealer: object.dealer,
            phoneList: try object.phoneList.map(phoneTransformer.transform(object:))
        )
        if let entity = entity as? T {
            return entity
        } else {
            throw RealmError.typeMismatch
        }
    }
}
