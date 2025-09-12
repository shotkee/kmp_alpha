//
//  RealmAnalyticsInsuranceProfileTransformer.swift
//  AlfaStrah
//
//  Created by vit on 13.06.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

class RealmAnalyticsInsuranceProfileTransformer<T: Entity>: RealmTransformer<T> {
	typealias EntityType = AnalyticsInsuranceProfile
	typealias RealmEntityType = RealmAnalyticsInsuranceProfile
	
	override var objectType: RealmEntity.Type {
		RealmEntityType.self
	}
	
	override func transform(entity: T) throws -> RealmEntity {
		guard let entity = entity as? EntityType else { throw RealmError.typeMismatch }

		let realmEntity = RealmEntityType()
		realmEntity.insurerFirstname = entity.insurerFirstname
		realmEntity.groupName = entity.groupName
		
		return realmEntity
	}
	
	override func transform(object: RealmEntity) throws -> T {
		guard let object = object as? RealmEntityType else { throw RealmError.typeMismatch }

		let entity = EntityType(
			insurerFirstname: object.insurerFirstname,
			groupName: object.groupName
		)
		
		if let entity = entity as? T {
			return entity
		} else {
			throw RealmError.typeMismatch
		}
	}
}
