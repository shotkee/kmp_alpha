//
//  RealmVehicleTransformer
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 13/02/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

class RealmVehicleTransformer<T: Entity>: RealmTransformer<T> {
    typealias EntityType = Vehicle
    typealias RealmEntityType = RealmVehicle

    override var objectType: RealmEntity.Type {
        RealmEntityType.self
    }

    override func transform(entity: T) throws -> RealmEntity {
        guard let entity = entity as? EntityType else { throw RealmError.typeMismatch }

        let realmEntity = RealmEntityType()
        realmEntity.registrationNumber = entity.registrationNumber
        realmEntity.power = entity.power
        realmEntity.vin = entity.vin
        realmEntity.yearOfIssue = entity.yearOfIssue
        realmEntity.registrationCertificateSeries = entity.registrationCertificateSeries
        realmEntity.registrationCertificateNumber = entity.registrationCertificateNumber
        realmEntity.keyCount = entity.keyCount ?? 0
        realmEntity.passportSeries = entity.passportSeries
        realmEntity.passportNumber = entity.passportNumber
        return realmEntity
    }

    override func transform(object: RealmEntity) throws -> T {
        guard let object = object as? RealmEntityType else { throw RealmError.typeMismatch }

        let entity = EntityType(
            registrationNumber: object.registrationNumber,
            power: object.power,
            vin: object.vin,
            yearOfIssue: object.yearOfIssue,
            registrationCertificateSeries: object.registrationCertificateSeries,
            registrationCertificateNumber: object.registrationCertificateNumber,
            keyCount: object.keyCount,
            passportSeries: object.passportSeries,
            passportNumber: object.passportNumber
        )
        if let entity = entity as? T {
            return entity
        } else {
            throw RealmError.typeMismatch
        }
    }
}
