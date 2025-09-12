//
//  RealmSosInsuredTransformer.swift
//  AlfaStrah
//
//  Created by Makson on 28.11.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

import Foundation

class RealmSosInsuredTransformer<T: Entity>: RealmTransformer<T> {
    typealias EntityType = SosInsured
    typealias RealmEntityType = RealmSosInsured
    
    private let insuranceTypeTransformer: RealmSosInsuranceTypeTransformer<InsuranceType> = .init()

    override var objectType: RealmEntity.Type {
        RealmEntityType.self
    }

    override func transform(entity: T) throws -> RealmEntity {
        guard let entity = entity as? EntityType else { throw RealmError.typeMismatch }

        let realmEntity = RealmEntityType()
        realmEntity.title = entity.title
        realmEntity.fullName = entity.fullName
        try entity.insuranceTypes.forEach {
            realmEntity.insuranceTypes.append(try insuranceTypeTransformer.transform(entity: $0))
        }
        
        return realmEntity
    }

    override func transform(object: RealmEntity) throws -> T {
        guard let object = object as? RealmEntityType else { throw RealmError.typeMismatch }

        let entity = EntityType(
            title: object.title,
            fullName: object.fullName,
            insuranceTypes: try object.insuranceTypes.map(insuranceTypeTransformer.transform(object: ))
        )
        
        if let entity = entity as? T {
            return entity
        } else {
            throw RealmError.typeMismatch
        }
    }
}
