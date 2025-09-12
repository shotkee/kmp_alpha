//
//  RealmBonusTransformer.swift
//  AlfaStrah
//
//  Created by vit on 19.06.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

import Foundation

class RealmBonusTransformer<T: Entity>: RealmTransformer<T> {
	typealias EntityType = Bonus
	typealias RealmEntityType = RealmBonus
	
	private let pointsTransformer: RealmPointsTransformer<Points> = .init()
	private let themedButtonTransformer: RealmThemedButtonTransformer<ThemedButton> = .init()
	private let themedValueTransformer: RealmThemedValueTransformer<ThemedValue> = .init()
	private let themedTextTransformer: RealmThemedTextTransformer<ThemedText> = .init()
	private let themedLinkTransformer: RealmThemedLinkTransformer<ThemedLink> = .init()
	
	override var objectType: RealmEntity.Type {
		RealmEntityType.self
	}

	override func transform(entity: T) throws -> RealmEntity {
		guard let entity = entity as? EntityType
		else { throw RealmError.typeMismatch }

		let realmEntity = RealmEntityType()
		realmEntity.points = try entity.points.map(pointsTransformer.transform(entity:))
		realmEntity.themedButton = try entity.themedButton.map(themedButtonTransformer.transform(entity:))
		realmEntity.themedDescription = try entity.themedDescription.map(themedTextTransformer.transform(entity:))
		realmEntity.themedTitle = try entity.themedTitle.map(themedTextTransformer.transform(entity:))
		realmEntity.themedImage = try entity.themedImage.map(themedValueTransformer.transform(entity:))
		realmEntity.themedBackgroundColor = try entity.themedBackgroundColor.map(themedValueTransformer.transform(entity:))
		realmEntity.themedLink = try entity.themedLink.map(themedLinkTransformer.transform(entity:))

		return realmEntity
	}

	override func transform(object: RealmEntity) throws -> T {
		guard let object = object as? RealmEntityType
		else { throw RealmError.typeMismatch }
		
		let entity = EntityType(
			points: try object.points.map(pointsTransformer.transform(object:)),
			themedButton: try object.themedButton.map(themedButtonTransformer.transform(object:)),
			themedDescription: try object.themedDescription.map(themedTextTransformer.transform(object:)),
			themedTitle: try object.themedTitle.map(themedTextTransformer.transform(object:)),
			themedImage: try object.themedImage.map(themedValueTransformer.transform(object:)),
			themedBackgroundColor: try object.themedBackgroundColor.map(themedValueTransformer.transform(object:)),
			themedLink: try object.themedLink.map(themedLinkTransformer.transform(object:))
		)
		
		if let entity = entity as? T {
			return entity
		} else {
			throw RealmError.typeMismatch
		}
	}
}
