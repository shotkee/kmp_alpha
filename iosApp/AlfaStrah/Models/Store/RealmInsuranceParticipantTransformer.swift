//
//  RealmInsuranceParticipantTransformer
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 13/02/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

class RealmInsuranceParticipantTransformer<T: Entity>: RealmTransformer<T> {
    typealias EntityType = InsuranceParticipant
    typealias RealmEntityType = RealmInsuranceParticipant

    override var objectType: RealmEntity.Type {
        RealmEntityType.self
    }

    override func transform(entity: T) throws -> RealmEntity {
        guard let entity = entity as? EntityType else { throw RealmError.typeMismatch }

        let realmEntity = RealmEntityType()
        realmEntity.fullName = entity.fullName
        realmEntity.firstName = entity.firstName
        realmEntity.lastName = entity.lastName
        realmEntity.birthDate = entity.birthDate
        realmEntity.sex = entity.sex
        realmEntity.contactInformation = entity.contactInformation
        realmEntity.fullAddress = entity.fullAddress
        return realmEntity
    }

    override func transform(object: RealmEntity) throws -> T {
        guard let object = object as? RealmEntityType else { throw RealmError.typeMismatch }

        let entity = EntityType(
            fullName: object.fullName,
            firstName: object.firstName,
            lastName: object.lastName,
            patronymic: object.patronymic,
            birthDate: object.birthDate,
            birthDateNonISO: object.birthDate,
            sex: object.sex,
            contactInformation: object.contactInformation,
            fullAddress: object.fullAddress
        )
        if let entity = entity as? T {
            return entity
        } else {
            throw RealmError.typeMismatch
        }
    }
}
