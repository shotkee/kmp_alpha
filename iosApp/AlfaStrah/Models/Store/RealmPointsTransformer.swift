//
//  RealmPointsTransformer.swift
//  AlfaStrah
//
//  Created by vit on 19.06.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

import Foundation

class RealmPointsTransformer<T: Entity>: RealmTransformer<T> {
	typealias EntityType = Points
	typealias RealmEntityType = RealmPoints
	
	private let themedTextTransformer: RealmThemedTextTransformer<ThemedText> = .init()
	private let themedValueTransformer: RealmThemedValueTransformer<ThemedValue> = .init()
	
	override var objectType: RealmEntity.Type {
		RealmEntityType.self
	}

	override func transform(entity: T) throws -> RealmEntity {
		guard let entity = entity as? EntityType
		else { throw RealmError.typeMismatch }

		let realmEntity = RealmEntityType()
		realmEntity.themedAmount = try entity.themedAmount.map(themedTextTransformer.transform(entity:))
		
		realmEntity.themedIcon = try entity.themedIcon.map(themedValueTransformer.transform(entity:))

		return realmEntity
	}

	override func transform(object: RealmEntity) throws -> T {
		guard let object = object as? RealmEntityType
		else { throw RealmError.typeMismatch }

		let entity = EntityType(
			themedAmount: try object.themedAmount.map(themedTextTransformer.transform(object:)),
			themedIcon: try object.themedIcon.map(themedValueTransformer.transform(object:))
		)

		if let entity = entity as? T {
			return entity
		} else {
			throw RealmError.typeMismatch
		}
	}
}
