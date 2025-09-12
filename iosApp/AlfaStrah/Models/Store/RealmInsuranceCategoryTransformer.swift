//
//  RealmInsuranceCategoryTransformer
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 13/02/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

class RealmInsuranceCategoryTransformer<T: Entity>: RealmTransformer<T> {
    typealias EntityType = InsuranceCategory
    typealias RealmEntityType = RealmInsuranceCategory

    override var objectType: RealmEntity.Type {
        RealmEntityType.self
    }

    override func transform(entity: T) throws -> RealmEntity {
        guard let entity = entity as? EntityType else { throw RealmError.typeMismatch }

        let realmEntity = RealmEntityType()
        realmEntity.id = entity.id
        realmEntity.title = entity.title
        realmEntity.termsURL = entity.termsURL?.absoluteString
        realmEntity.sortPriority = entity.sortPriority
        realmEntity.daysLeft = entity.daysLeft
        entity.productIds.forEach {
            realmEntity.productIds.append($0)
        }
        realmEntity.kind = entity.kind.rawValue
        realmEntity.subtitle = entity.subtitle
        return realmEntity
    }

    override func transform(object: RealmEntity) throws -> T {
        guard let object = object as? RealmEntityType else { throw RealmError.typeMismatch }

        guard !object.id.isEmpty else { throw RealmError.typeMismatch }
        guard let kind = InsuranceCategory.CategoryKind(rawValue: object.kind) else { throw RealmError.typeMismatch }

        let entity = EntityType(
            id: object.id,
            title: object.title,
            termsURL: object.termsURL.flatMap(URL.init(string:)),
            sortPriority: object.sortPriority,
            daysLeft: object.daysLeft,
            productIds: Array(object.productIds),
            kind: kind,
            subtitle: object.subtitle
        )
        if let entity = entity as? T {
            return entity
        } else {
            throw RealmError.typeMismatch
        }
    }
}
