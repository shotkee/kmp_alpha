//
//  RealmInsuranceRenderTransformer.swift
//  AlfaStrah
//
//  Created by vit on 27.05.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

import Foundation

class RealmInsuranceRenderTransformer<T: Entity>: RealmTransformer<T> {
	typealias EntityType = InsuranceRender
	typealias RealmEntityType = RealmInsuranceRender
	
	private let headersTransformer: RealmInsuranceRenderHeaderTransformer<InsuranceRenderHeader> = .init()
	
	override var objectType: RealmEntity.Type {
		RealmEntityType.self
	}

	override func transform(entity: T) throws -> RealmEntity {
		guard let entity = entity as? EntityType
		else { throw RealmError.typeMismatch }

		let realmEntity = RealmEntityType()
		realmEntity.method = entity.method.rawValue
		realmEntity.postBody = entity.postBody
		realmEntity.type = entity.type.rawValue
		realmEntity.url = entity.url?.absoluteString

		try entity.headers.forEach {
			realmEntity.headers.append(try headersTransformer.transform(entity: $0))
		}
		
		return realmEntity
	}

	override func transform(object: RealmEntity) throws -> T {
		guard let object = object as? RealmEntityType,
			  let method = Method(rawValue: object.method),
			  let type = BackendComponentType(rawValue: object.type)
		else { throw RealmError.typeMismatch }
		
		let entity = EntityType(
			method: method,
			postBody: object.postBody,
			type: type,
			url: object.url.flatMap(URL.init(string:)),
			headers: try object.headers.map(headersTransformer.transform(object:))
		)
		
		if let entity = entity as? T {
			return entity
		} else {
			throw RealmError.typeMismatch
		}
	}
}

class RealmInsuranceRenderHeaderTransformer<T: Entity>: RealmTransformer<T> {
	typealias EntityType = InsuranceRenderHeader
	typealias RealmEntityType = RealmInsuranceRenderHeader
	
	override func transform(entity: T) throws -> RealmEntity {
		guard let entity = entity as? EntityType
		else { throw RealmError.typeMismatch }
		
		let realmEntity = RealmEntityType()
		realmEntity.value = entity.value
		realmEntity.name = entity.name
		
		return realmEntity
	}
	
	override func transform(object: RealmEntity) throws -> T {
		guard let object = object as? RealmEntityType
		else { throw RealmError.typeMismatch }
		
		let entity = EntityType(
			value: object.value,
			name: object.name)
		
		if let entity = entity as? T {
			return entity
		} else {
			throw RealmError.typeMismatch
		}
	}
}
