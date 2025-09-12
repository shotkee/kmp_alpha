//
//  RealmInsuranceMainTransformer.swift
//  AlfaStrah
//
//  Created by Evgeny Ivanov on 12/04/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

class RealmInsuranceMainTransformer<T: Entity>: RealmTransformer<T> {
    typealias EntityType = InsuranceMain
    typealias RealmEntityType = RealmInsuranceMain

    private let sosModelTransformer: RealmSosModelTransformer<SosModel> = .init()
	private let insuranceGroupTransformer: RealmInsuranceGroupTransformer<InsuranceGroup> = .init()
    private let sosEmergencyCommunicationTransformer: RealmSosEmergencyCommunicationTransformer<SosEmergencyCommunication> = .init()

    override var objectType: RealmEntity.Type {
        RealmEntityType.self
    }

    override func transform(entity: T) throws -> RealmEntity {
        guard let entity = entity as? EntityType
        else { throw RealmError.typeMismatch }

        let realmEntity = RealmEntityType()

        try entity.insuranceGroupList.forEach {
            realmEntity.insuranceGroupList.append(try insuranceGroupTransformer.transform(entity: $0))
        }
        try entity.sosList.forEach {
            realmEntity.sosList.append(try sosModelTransformer.transform(entity: $0))
        }
        
        realmEntity.sosEmergencyCommunication = try entity.sosEmergencyCommunication.map(
            sosEmergencyCommunicationTransformer.transform(entity:)
        )
        return realmEntity
    }

    override func transform(object: RealmEntity) throws -> T {
        guard let object = object as? RealmEntityType,
              let sosEmergencyCommunication = object.sosEmergencyCommunication
        else { throw RealmError.typeMismatch }

        let entity = EntityType(
            insuranceGroupList: try object.insuranceGroupList.map(insuranceGroupTransformer.transform(object: )),
            sosList: try object.sosList.map(sosModelTransformer.transform(object: )),
            sosEmergencyCommunication: try object.sosEmergencyCommunication.map(sosEmergencyCommunicationTransformer.transform(object:))
        )
        if let entity = entity as? T {
            return entity
        } else {
            throw RealmError.typeMismatch
        }
    }
}
