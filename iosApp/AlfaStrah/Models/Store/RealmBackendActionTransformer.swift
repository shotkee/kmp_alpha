//
//  RealmBackendActionTransformer.swift
//  AlfaStrah
//
//  Created by vit on 19.06.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

import Foundation

class RealmBackendActionTransformer<T: Entity>: RealmTransformer<T> {
	typealias EntityType = BackendAction
	typealias RealmEntityType = RealmBackendAction
		
	override var objectType: RealmEntity.Type {
		RealmEntityType.self
	}

	override func transform(entity: T) throws -> RealmEntity {
		guard let entity = entity as? EntityType
		else { throw RealmError.typeMismatch }

		let realmEntity = RealmEntityType()
		realmEntity.title = entity.title
		realmEntity.internalType = entity.internalType.rawValue
		
		if let additionalParameters = entity.additionalParameters{
			realmEntity.additionalParameters = try? JSONSerialization.data(withJSONObject: additionalParameters)
		}
		
		return realmEntity
	}

	override func transform(object: RealmEntity) throws -> T {
		guard let object = object as? RealmEntityType,
			  let internalType = BackendAction.InternalActionType(rawValue: object.internalType)
		else { throw RealmError.typeMismatch }
		
		let entity = EntityType(
			title: object.title,
			internalType: internalType,
			additionalParameters: {
				guard let parametersData = object.additionalParameters
				else { return nil }
				
				return try? JSONSerialization.jsonObject(with: parametersData) as? [String: Any]
			}()
		)
		
		if let entity = entity as? T {
			return entity
		} else {
			throw RealmError.typeMismatch
		}
	}
}
