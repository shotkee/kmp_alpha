//
//  RealmSosEmergencyConnectionScreenInformationTransformer.swift
//  AlfaStrah
//
//  Created by Makson on 28.11.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

import Foundation

// swiftlint:disable type_name
class RealmSosEmergencyConnectionScreenInformationTransformer<T: Entity>: RealmTransformer<T> {
    typealias EntityType = SosEmergencyConnectionScreenInformation
    typealias RealmEntityType = RealmSosEmergencyConnectionScreenInformation
	
	private let themedValueTransformer: RealmThemedValueTransformer<ThemedValue> = .init()

    override var objectType: RealmEntity.Type {
        RealmEntityType.self
    }

    override func transform(entity: T) throws -> RealmEntity {
        guard let entity = entity as? EntityType else { throw RealmError.typeMismatch }

		let realmEntity = RealmEntityType()
        realmEntity.title = entity.title
        realmEntity.icon = entity.icon
		realmEntity.iconThemed = try entity.iconThemed.map(themedValueTransformer.transform(entity:))
        
        return realmEntity
    }

    override func transform(object: RealmEntity) throws -> T {
        guard let object = object as? RealmEntityType else { throw RealmError.typeMismatch }

        let entity = EntityType(
            title: object.title,
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
