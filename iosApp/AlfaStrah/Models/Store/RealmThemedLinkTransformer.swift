//
//  RealmThemedLinkTransformer.swift
//  AlfaStrah
//
//  Created by vit on 21.06.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

import Foundation

class RealmThemedLinkTransformer<T: Entity>: RealmTransformer<T> {
	typealias EntityType = ThemedLink
	typealias RealmEntityType = RealmThemedLink
	
	private let themedTextTransformer: RealmThemedTextTransformer<ThemedText> = .init()
	
	override var objectType: RealmEntity.Type {
		RealmEntityType.self
	}

	override func transform(entity: T) throws -> RealmEntity {
		guard let entity = entity as? EntityType
		else { throw RealmError.typeMismatch }

		let realmEntity = RealmEntityType()
		
		realmEntity.url = entity.url?.absoluteString
		realmEntity.themedThext = try entity.themedText.map(themedTextTransformer.transform(entity:))

		return realmEntity
	}

	override func transform(object: RealmEntity) throws -> T {
		guard let object = object as? RealmEntityType
		else { throw RealmError.typeMismatch }
		
		let entity = EntityType(
			url: object.url.flatMap(URL.init(string:)),
			themedText: try object.themedThext.map(themedTextTransformer.transform(object:))
		)
		
		if let entity = entity as? T {
			return entity
		} else {
			throw RealmError.typeMismatch
		}
	}
}
