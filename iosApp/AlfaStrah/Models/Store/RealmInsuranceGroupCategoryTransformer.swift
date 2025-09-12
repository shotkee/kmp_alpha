//
//  RealmInsuranceGroupCategoryTransformer.swift
//  AlfaStrah
//
//  Created by Evgeny Ivanov on 12/04/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

class RealmInsuranceGroupCategoryTransformer<T: Entity>: RealmTransformer<T> {
    typealias EntityType = InsuranceGroupCategory
    typealias RealmEntityType = RealmInsuranceGroupCategory

    private let insuranceCategoryMaiTransformer: RealmInsuranceCategoryMainTransformer<InsuranceCategoryMain> = .init()
    private let sosActivityModelTransformer: RealmSosActivityModelTransformer<SosActivityModel> = .init()
    private let insuranceShortTransformer: RealmInsuranceShortTransformer<InsuranceShort> = .init()

    override var objectType: RealmEntity.Type {
        RealmEntityType.self
    }

    override func transform(entity: T) throws -> RealmEntity {
        guard let entity = entity as? EntityType else { throw RealmError.typeMismatch }

        let realmEntity = RealmEntityType()
        if let sosActivity = entity.sosActivity {
            realmEntity.sosActivity = try sosActivityModelTransformer.transform(entity: sosActivity)
        }
        realmEntity.insuranceCategory = try insuranceCategoryMaiTransformer.transform(entity: entity.insuranceCategory)
        try entity.insuranceList.forEach {
            realmEntity.insuranceList.append(try insuranceShortTransformer.transform(entity: $0))
        }
        return realmEntity
    }

    override func transform(object: RealmEntity) throws -> T {
        guard let object = object as? RealmEntityType else { throw RealmError.typeMismatch }

        guard let insuranceCategory = object.insuranceCategory else { throw RealmError.typeMismatch }

        var sos: SosActivityModel?
        if let sosActivity = object.sosActivity {
            sos = try sosActivityModelTransformer.transform(object: sosActivity)
        }

        let entity = EntityType(
            insuranceCategory: try insuranceCategoryMaiTransformer.transform(object: insuranceCategory),
            insuranceList: try object.insuranceList.map(insuranceShortTransformer.transform(object: )),
            sosActivity: sos
        )
        if let entity = entity as? T {
            return entity
        } else {
            throw RealmError.typeMismatch
        }
    }
}
