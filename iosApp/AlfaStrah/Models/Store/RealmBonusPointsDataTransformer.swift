//
//  RealmBonusPointsDataTransformer.swift
//  AlfaStrah
//
//  Created by vit on 19.06.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

import Foundation

class RealmBonusPointsDataTransformer<T: Entity>: RealmTransformer<T> {
	typealias EntityType = BonusPointsData
	typealias RealmEntityType = RealmBonusPointsData
	
	private let themedTextTransformer: RealmThemedTextTransformer<ThemedText> = .init()
	private let themedValueTransformer: RealmThemedValueTransformer<ThemedValue> = .init()
	private let bonusTransformer: RealmBonusTransformer<Bonus> = .init()
	
	override var objectType: RealmEntity.Type {
		RealmEntityType.self
	}

	override func transform(entity: T) throws -> RealmEntity {
		guard let entity = entity as? EntityType
		else { throw RealmError.typeMismatch }

		let realmEntity = RealmEntityType()
		realmEntity.themedTitle = try entity.themedTitle.map(themedTextTransformer.transform(entity:))

		try (entity.themedIcons).forEach {
			realmEntity.themedIcons.append(try themedValueTransformer.transform(entity: $0))
		}
		
		try (entity.bonuses).forEach {
			realmEntity.bonuses.append(try bonusTransformer.transform(entity: $0))
		}

		return realmEntity
	}

	override func transform(object: RealmEntity) throws -> T {
		guard let object = object as? RealmEntityType
		else { throw RealmError.typeMismatch }
		
		let entity = EntityType(
			themedTitle: try object.themedTitle.map(themedTextTransformer.transform(object:)),
			themedIcons: try object.themedIcons.map(themedValueTransformer.transform(object:)),
			bonuses: try object.bonuses.map(bonusTransformer.transform(object:))
		)
		
		if let entity = entity as? T {
			return entity
		} else {
			throw RealmError.typeMismatch
		}
	}
}
