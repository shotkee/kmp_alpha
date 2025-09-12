//
//  RealmInsuranceCategoryMainTransformer.swift
//  AlfaStrah
//
//  Created by Evgeny Ivanov on 11/04/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

class RealmInsuranceCategoryMainTransformer<T: Entity>: RealmTransformer<T> {
    typealias EntityType = InsuranceCategoryMain
    typealias RealmEntityType = RealmInsuranceCategoryMain
	private let themedValueTransformer: RealmThemedValueTransformer<ThemedValue> = .init()

    override var objectType: RealmEntity.Type {
        RealmEntityType.self
    }

    override func transform(entity: T) throws -> RealmEntity {
        guard let entity = entity as? EntityType else { throw RealmError.typeMismatch }

        let realmEntity = RealmEntityType()
        realmEntity.id = entity.id
        realmEntity.title = entity.title
        realmEntity.categoryDescription = entity.description
        realmEntity.type = entity.type.rawValue
        realmEntity.icon = entity.icon
		realmEntity.iconThemed = try entity.iconThemed.map(themedValueTransformer.transform(entity:))
        
        return realmEntity
    }

    override func transform(object: RealmEntity) throws -> T {
        guard let object = object as? RealmEntityType else { throw RealmError.typeMismatch }

        guard let type = InsuranceCategoryMain.CategoryType(rawValue: object.type) else { throw RealmError.typeMismatch }

        let entity = EntityType(
            id: object.id,
            title: object.title,
            description: object.categoryDescription,
            type: type,
            icon: object.icon,
			iconThemed: try object.iconThemed.map(themedValueTransformer.transform(object:))
        )
        if let entity = entity as? T {
            return entity
        } else {
            throw RealmError.typeMismatch
        }
    }
}
