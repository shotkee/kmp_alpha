//
//  RealmThemedButtonTransformer.swift
//  AlfaStrah
//
//  Created by vit on 19.06.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

import Foundation

class RealmThemedButtonTransformer<T: Entity>: RealmTransformer<T> {
	typealias EntityType = ThemedButton
	typealias RealmEntityType = RealmThemedButton
	
	private let backendActionTransformer: RealmBackendActionTransformer<BackendAction> = .init()
	private let themedValueTransformer: RealmThemedValueTransformer<ThemedValue> = .init()
	
	override var objectType: RealmEntity.Type {
		RealmEntityType.self
	}

	override func transform(entity: T) throws -> RealmEntity {
		guard let entity = entity as? EntityType
		else { throw RealmError.typeMismatch }

		let realmEntity = RealmEntityType()
		
		realmEntity.themedTextColor = try entity.themedTextColor.map(themedValueTransformer.transform(entity:))
		realmEntity.themedBackgroundColor = try entity.themedBackgroundColor.map(themedValueTransformer.transform(entity:))
		realmEntity.themedBorderColor = try entity.themedBorderColor.map(themedValueTransformer.transform(entity:))
		
		realmEntity.action = try entity.action.map(backendActionTransformer.transform(entity:))
		
		return realmEntity
	}

	override func transform(object: RealmEntity) throws -> T {
		guard let object = object as? RealmEntityType
		else { throw RealmError.typeMismatch }
		
		let entity = EntityType(
			themedTextColor: try object.themedTextColor.map(themedValueTransformer.transform(object:)),
			themedBackgroundColor: try object.themedBackgroundColor.map(themedValueTransformer.transform(object:)),
			themedBorderColor: try object.themedBorderColor.map(themedValueTransformer.transform(object:)),
			action: try object.action.map(backendActionTransformer.transform(object:))
		)
		
		if let entity = entity as? T {
			return entity
		} else {
			throw RealmError.typeMismatch
		}
	}
}
