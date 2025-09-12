//
//  RealmSosEmergencyCommunicationItemTransformer.swift
//  AlfaStrah
//
//  Created by Makson on 09.11.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

import Foundation

class RealmSosEmergencyCommunicationItemTransformer<T: Entity>: RealmTransformer<T> {
    typealias EntityType = SosEmergencyCommunicationItem
    typealias RealmEntityType = RealmSosEmergencyCommunicationItem
    
    private let sosUXPhoneTransformer: RealmSosUXPhoneTransformer<SosUXPhone> = .init()
	private let themedValueTransformer: RealmThemedValueTransformer<ThemedValue> = .init()
    
    override var objectType: RealmEntity.Type {
        RealmEntityType.self
    }

    override func transform(entity: T) throws -> RealmEntity {
        guard let entity = entity as? EntityType else { throw RealmError.typeMismatch }

        let realmEntity = RealmEntityType()
        realmEntity.icon = entity.icon
		realmEntity.iconThemed = try entity.iconThemed.map(themedValueTransformer.transform(entity:))
        realmEntity.rightIcon = entity.rightIcon
		realmEntity.rightIconThemed = try entity.rightIconThemed.map(themedValueTransformer.transform(entity:))
        realmEntity.title = entity.title
        realmEntity.titlePopup = entity.titlePopup
        realmEntity.phone = try sosUXPhoneTransformer.transform(entity: entity.phone)
        
        return realmEntity
    }

    override func transform(object: RealmEntity) throws -> T {
        guard let object = object as? RealmEntityType,
              let phone = object.phone
        else { throw RealmError.typeMismatch }

        let entity = EntityType(
            icon: object.icon,
			iconThemed: try object.iconThemed.map(themedValueTransformer.transform(object:)),
            rightIcon: object.rightIcon,
			rightIconThemed: try object.rightIconThemed.map(themedValueTransformer.transform(object:)),
            title: object.title,
            titlePopup: object.titlePopup,
            phone: try sosUXPhoneTransformer.transform(object: phone)
        )
        
        if let entity = entity as? T {
            return entity
        } else {
            throw RealmError.typeMismatch
        }
    }
}
