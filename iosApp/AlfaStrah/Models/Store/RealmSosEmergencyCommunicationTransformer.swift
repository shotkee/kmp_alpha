//
//  RealmSosEmergencyCommunicationTransformer.swift
//  AlfaStrah
//
//  Created by Makson on 09.11.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

import Foundation

// swiftlint:disable line_length
class RealmSosEmergencyCommunicationTransformer<T: Entity>: RealmTransformer<T> {
    typealias EntityType = SosEmergencyCommunication
    typealias RealmEntityType = RealmSosEmergencyCommunication
    
    private let sosEmergencyConnectionScreenInformationTransformer: RealmSosEmergencyConnectionScreenInformationTransformer<SosEmergencyConnectionScreenInformation> = .init()
    private let sosEmergencyCommunicationBlockTransformer: RealmSosEmergencyCommunicationBlockTransformer<SosEmergencyCommunicationBlock> = .init()
	private let confidantTransformer: RealmConfidantTransformer<Confidant> = .init()
	private let confidantBannerTransformer: RealmConfidantBannerTransformer<ConfidantBanner> = .init()

    override var objectType: RealmEntity.Type {
        RealmEntityType.self
    }

    override func transform(entity: T) throws -> RealmEntity {
        guard let entity = entity as? EntityType else { throw RealmError.typeMismatch }

        let realmEntity = RealmEntityType()
        realmEntity.title = entity.title
        realmEntity.information = try entity.information.map(sosEmergencyConnectionScreenInformationTransformer.transform(entity:))
        realmEntity.communicationBlock = try entity.communicationBlock.map(sosEmergencyCommunicationBlockTransformer.transform(entity:))
		realmEntity.confidant = try entity.confidant.map(confidantTransformer.transform(entity:))
		realmEntity.confidantBanner = try entity.confidantBanner.map(confidantBannerTransformer.transform(entity:))
		
        return realmEntity
    }

    override func transform(object: RealmEntity) throws -> T {
        guard let object = object as? RealmEntityType else { throw RealmError.typeMismatch }

        let entity = EntityType(
            title: object.title,
            information: try object.information.map(sosEmergencyConnectionScreenInformationTransformer.transform(object:)),
            communicationBlock: try object.communicationBlock.map(sosEmergencyCommunicationBlockTransformer.transform(object:)),
			confidant: try object.confidant.map(confidantTransformer.transform(object:)),
			confidantBanner: try object.confidantBanner.map(confidantBannerTransformer.transform(object:))
        )
        if let entity = entity as? T {
            return entity
        } else {
            throw RealmError.typeMismatch
        }
    }
}
