//
//  RealmConfidantBannerTransformer.swift
//  AlfaStrah
//
//  Created by Makson on 06.08.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

import Foundation

// swiftlint:disable type_name
class RealmConfidantBannerTransformer<T: Entity>: RealmTransformer<T> {
	typealias EntityType = ConfidantBanner
	typealias RealmEntityType = RealmConfidantBanner
	
	override var objectType: RealmEntity.Type {
		RealmEntityType.self
	}

	override func transform(entity: T) throws -> RealmEntity {
		guard let entity = entity as? EntityType else { throw RealmError.typeMismatch }

		let realmEntity = RealmEntityType()
		realmEntity.title = entity.title
		realmEntity.subtitle = entity.description
		
		return realmEntity
	}

	override func transform(object: RealmEntity) throws -> T {
		guard let object = object as? RealmEntityType else { throw RealmError.typeMismatch }

		let entity = EntityType(
			title: object.title,
			description: object.subtitle
		)
		
		if let entity = entity as? T {
			return entity
		} else {
			throw RealmError.typeMismatch
		}
	}
}
