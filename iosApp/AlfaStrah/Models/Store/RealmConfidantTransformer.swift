//
//  RealmConfidantTransformer.swift
//  AlfaStrah
//
//  Created by Makson on 06.08.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

import Foundation

// swiftlint:disable type_name
class RealmConfidantTransformer<T: Entity>: RealmTransformer<T> {
	typealias EntityType = Confidant
	typealias RealmEntityType = RealmConfidant
	
	private let phoneTransformer: RealmPhoneTransformer<Phone> = .init()

	override var objectType: RealmEntity.Type {
		RealmEntityType.self
	}

	override func transform(entity: T) throws -> RealmEntity {
		guard let entity = entity as? EntityType else { throw RealmError.typeMismatch }

		let realmEntity = RealmEntityType()
		realmEntity.name = entity.name
		realmEntity.phone = try phoneTransformer.transform(entity: entity.phone)
		
		return realmEntity
	}

	override func transform(object: RealmEntity) throws -> T {
		guard let object = object as? RealmEntityType else { throw RealmError.typeMismatch }
		guard let phone = object.phone else { throw RealmError.typeMismatch }

		let entity = EntityType(
			name: object.name,
			phone: try phoneTransformer.transform(object: phone)
		)
		
		if let entity = entity as? T {
			return entity
		} else {
			throw RealmError.typeMismatch
		}
	}
}
