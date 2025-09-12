//
//  RealmInfoFieldTransformer
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 13/02/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

class RealmInfoFieldTransformer<T: Entity>: RealmTransformer<T> {
    typealias EntityType = InfoField
    typealias RealmEntityType = RealmInfoField

    private let coordinateTransformer: RealmCoordinateTransformer<Coordinate> = .init()

    override var objectType: RealmEntity.Type {
        RealmEntityType.self
    }

    override func transform(entity: T) throws -> RealmEntity {
        guard let entity = entity as? EntityType else { throw RealmError.typeMismatch }

        let realmEntity = RealmEntityType()
        realmEntity.type = entity.type.rawValue
        realmEntity.title = entity.title
        realmEntity.text = entity.text
        realmEntity.coordinate = try entity.coordinate.map(coordinateTransformer.transform(entity:))
        return realmEntity
    }

    override func transform(object: RealmEntity) throws -> T {
        guard let object = object as? RealmEntityType else { throw RealmError.typeMismatch }

        guard let type = InfoField.Kind(rawValue: object.type) else { throw RealmError.typeMismatch }

        let entity = EntityType(
            type: type,
            title: object.title,
            text: object.text,
            coordinate: try object.coordinate.map(coordinateTransformer.transform(object:))
        )
        if let entity = entity as? T {
            return entity
        } else {
            throw RealmError.typeMismatch
        }
    }
}
