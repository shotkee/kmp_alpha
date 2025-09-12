//
//  RealmThemedTextTransformer.swift
//  AlfaStrah
//
//  Created by vit on 19.06.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

import Foundation

class RealmThemedTextTransformer<T: Entity>: RealmTransformer<T> {
	typealias EntityType = ThemedText
	typealias RealmEntityType = RealmThemedText
	
	private let themedValueTransformer: RealmThemedValueTransformer<ThemedValue> = .init()
	
	override var objectType: RealmEntity.Type {
		RealmEntityType.self
	}

	override func transform(entity: T) throws -> RealmEntity {
		guard let entity = entity as? EntityType
		else { throw RealmError.typeMismatch }

		let realmEntity = RealmEntityType()
		realmEntity.text = entity.text
		realmEntity.themedColor = try entity.themedColor.map(themedValueTransformer.transform(entity:))

		return realmEntity
	}

	override func transform(object: RealmEntity) throws -> T {
		guard let object = object as? RealmEntityType
		else { throw RealmError.typeMismatch }
		
		let entity = EntityType(
			text: object.text,
			themedColor: try object.themedColor.map(themedValueTransformer.transform(object:))
		)
		
		if let entity = entity as? T {
			return entity
		} else {
			throw RealmError.typeMismatch
		}
	}
}
