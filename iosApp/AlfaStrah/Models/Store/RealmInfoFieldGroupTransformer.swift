//
//  RealmInfoFieldGroupTransformer
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 13/02/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

class RealmInfoFieldGroupTransformer<T: Entity>: RealmTransformer<T> {
    typealias EntityType = InfoFieldGroup
    typealias RealmEntityType = RealmInfoFieldGroup

    private let fieldTransformer: RealmInfoFieldTransformer<InfoField> = .init()

    override var objectType: RealmEntity.Type {
        RealmEntityType.self
    }

    override func transform(entity: T) throws -> RealmEntity {
        guard let entity = entity as? EntityType else { throw RealmError.typeMismatch }

        let realmEntity = RealmEntityType()
        realmEntity.title = entity.title
        try entity.fields.forEach {
            realmEntity.fields.append(try fieldTransformer.transform(entity: $0))
        }
        return realmEntity
    }

    override func transform(object: RealmEntity) throws -> T {
        guard let object = object as? RealmEntityType else { throw RealmError.typeMismatch }

        let entity = EntityType(
            title: object.title,
            fields: try object.fields.map(fieldTransformer.transform(object:))
        )
        if let entity = entity as? T {
            return entity
        } else {
            throw RealmError.typeMismatch
        }
    }
}
