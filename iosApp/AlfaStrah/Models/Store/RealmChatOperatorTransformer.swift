//
//  RealmChatOperatorTransformer.swift
//  AlfaStrah
//
//  Created by vit on 03.07.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

import Foundation

class RealmChatOperatorTransformer<T: Entity>: RealmTransformer<T> {
	typealias EntityType = CascanaChatOperator
	typealias RealmEntityType = RealmChatOperator
	
	override var objectType: RealmEntity.Type {
		RealmEntityType.self
	}

	override func transform(entity: T) throws -> RealmEntity {
		guard let entity = entity as? EntityType
		else { throw RealmError.typeMismatch }

		let realmEntity = RealmEntityType()
		realmEntity.senderId = entity.getSenderId()
		realmEntity.requestId = entity.getRequestId()
		realmEntity.name = entity.getName()
		realmEntity.rate.value = entity.getRate()

		return realmEntity
	}

	override func transform(object: RealmEntity) throws -> T {
		guard let object = object as? RealmEntityType
		else { throw RealmError.typeMismatch }
		
		let entity = EntityType(
			name: object.name ?? "",
			senderId: object.senderId,
			requestId: object.requestId,
			rate: object.rate.value
		)
		
		if let entity = entity as? T {
			return entity
		} else {
			throw RealmError.typeMismatch
		}
	}
}
