//
//  RealmChatFileEntryTransformer.swift
//  AlfaStrah
//
//  Created by vit on 18.03.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

import RealmSwift

class RealmChatFileEntryTransformer<T: Entity>: RealmTransformer<T> {
	typealias EntityType = ChatFileEntry
	typealias RealmEntityType = RealmChatFileEntry
	
	override var objectType: RealmEntity.Type {
		RealmEntityType.self
	}

	override func transform(entity: T) throws -> RealmEntity {
		guard let entity = entity as? EntityType
		else { throw RealmError.typeMismatch }

		let realmEntity = RealmEntityType()
		realmEntity.id = entity.id
		realmEntity.remoteUrlPathBase64Encoded = entity.remoteUrlPathBase64Encoded
		realmEntity.filename = entity.filename
		realmEntity.expirationDate = entity.expirationDate
		
		return realmEntity
	}

	override func transform(object: RealmEntity) throws -> T {
		guard let object = object as? RealmEntityType
		else { throw RealmError.typeMismatch }
		
		let entity = EntityType(
			id: object.id,
			remoteUrlPathBase64Encoded: object.remoteUrlPathBase64Encoded,
			filename: object.filename,
			expirationDate: object.expirationDate
		)
		
		if let entity = entity as? T {
			return entity
		} else {
			throw RealmError.typeMismatch
		}
	}
}
