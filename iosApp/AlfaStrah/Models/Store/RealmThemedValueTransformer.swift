//
//  RealmThemedValueTransformer.swift
//  AlfaStrah
//
//  Created by mac on 06.03.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

import Foundation

class RealmThemedValueTransformer<T: Entity>: RealmTransformer<T> {
	typealias EntityType = ThemedValue
	typealias RealmEntityType = RealmThemedValue
	
	override var objectType: RealmEntity.Type {
		RealmEntityType.self
	}

	override func transform(entity: T) throws -> RealmEntity {
		guard let entity = entity as? EntityType else { throw RealmError.typeMismatch }

		let realmEntity = RealmEntityType()
		realmEntity.dark = entity.dark
		realmEntity.light = entity.light
		return realmEntity
	}

	override func transform(object: RealmEntity) throws -> T {
		guard let object = object as? RealmEntityType else { throw RealmError.typeMismatch }

		let entity = EntityType(light: object.light, dark: object.dark)
		
		if let entity = entity as? T {
			return entity
		} else {
			throw RealmError.typeMismatch
		}
	}
}
