//
//  RealmSosModelTransformer.swift
//  AlfaStrah
//
//  Created by Evgeny Ivanov on 12/04/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

class RealmSosModelTransformer<T: Entity>: RealmTransformer<T> {
    typealias EntityType = SosModel
    typealias RealmEntityType = RealmSosModel

    private let insuranceCategoryMainTransformer: RealmInsuranceCategoryMainTransformer<InsuranceCategoryMain> = .init()
    private let instructionTransformer: RealmInstructionTransformer<Instruction> = .init()
    private let sosActivityModelTransformer: RealmSosActivityModelTransformer<SosActivityModel> = .init()
    private let sosPhoneTransformer: RealmSosPhoneTransformer<SosPhone> = .init()

    override var objectType: RealmEntity.Type {
        RealmEntityType.self
    }

    override func transform(entity: T) throws -> RealmEntity {
        guard let entity = entity as? EntityType else { throw RealmError.typeMismatch }

        let realmEntity = RealmEntityType()
        realmEntity.insuranceCategory = try entity.insuranceCategory.map(insuranceCategoryMainTransformer.transform(entity:))
        realmEntity.sosPhone = try entity.sosPhone.map(sosPhoneTransformer.transform(entity:))
        realmEntity.kind = entity.kind.rawValue
        try entity.instructionList.forEach {
            realmEntity.instructionList.append(try instructionTransformer.transform(entity: $0))
        }
        try entity.sosActivityList.forEach {
            realmEntity.sosActivityList.append(try sosActivityModelTransformer.transform(entity: $0))
        }
        realmEntity.isHealthFlow = entity.isHealthFlow
        realmEntity.isActive = entity.isActive
        realmEntity.insuranceCount = entity.insuranceCount
        return realmEntity
    }

    override func transform(object: RealmEntity) throws -> T {
        guard let object = object as? RealmEntityType else { throw RealmError.typeMismatch }

        guard let kind = SosModel.SosModelKind(rawValue: object.kind) else { throw RealmError.typeMismatch }

        let entity = EntityType(
            kind: kind,
            insuranceCategory: try object.insuranceCategory.map(insuranceCategoryMainTransformer.transform(object:)),
            sosPhone: try object.sosPhone.map(sosPhoneTransformer.transform(object:)),
            isActive: object.isActive,
            isHealthFlow: object.isHealthFlow,
            insuranceCount: object.insuranceCount,
            instructionList: try object.instructionList.map(instructionTransformer.transform(object: )),
            sosActivityList: try object.sosActivityList.map(sosActivityModelTransformer.transform(object: ))
        )
        if let entity = entity as? T {
            return entity
        } else {
            throw RealmError.typeMismatch
        }
    }
}
