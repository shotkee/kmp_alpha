//
//  RealmInsuranceTransformer
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 13/02/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

class RealmInsuranceTransformer<T: Entity>: RealmTransformer<T> {
    typealias EntityType = Insurance
    typealias RealmEntityType = RealmInsurance

    private let participantTransformer: RealmInsuranceParticipantTransformer<InsuranceParticipant> = .init()
    private let vehicleTransformer: RealmVehicleTransformer<Vehicle> = .init()
    private let tripTransformer: RealmTripSegmentTransformer<TripSegment> = .init()
    private let fieldGroupTransformer: RealmInfoFieldGroupTransformer<InfoFieldGroup> = .init()
    private let phoneTransformer: RealmPhoneTransformer<Phone> = .init()
    private let billsTransformer: RealmInsuranceBillTransformer<InsuranceBill> = .init()

    override var objectType: RealmEntity.Type {
        RealmEntityType.self
    }

    override func transform(entity: T) throws -> RealmEntity {
        guard let entity = entity as? EntityType else { throw RealmError.typeMismatch }

        let realmEntity = RealmEntityType()
        realmEntity.id = entity.id
        realmEntity.title = entity.title
        realmEntity.contractNumber = entity.contractNumber
        realmEntity.startDate = entity.startDate
        realmEntity.endDate = entity.endDate
        realmEntity.objectDescription = entity.description
        realmEntity.insurancePremium = entity.insurancePremium
        try entity.ownerParticipants.forEach {
            realmEntity.ownerParticipants.append(try participantTransformer.transform(entity: $0))
        }
        try (entity.insurerParticipants ?? []).forEach {
            realmEntity.insurerParticipants.append(try participantTransformer.transform(entity: $0))
        }
        try (entity.insuredParticipants ?? []).forEach {
            realmEntity.insuredParticipants.append(try participantTransformer.transform(entity: $0))
        }
        try (entity.benefitParticipants ?? []).forEach {
            realmEntity.benefitParticipants.append(try participantTransformer.transform(entity: $0))
        }
        try (entity.drivers ?? []).forEach {
            realmEntity.drivers.append(try participantTransformer.transform(entity: $0))
        }
        realmEntity.vehicle = try entity.vehicle.map(vehicleTransformer.transform(entity:))
        try (entity.tripSegments ?? []).forEach {
            realmEntity.tripSegments.append(try tripTransformer.transform(entity: $0))
        }
        realmEntity.productId = entity.productId
        realmEntity.renewAvailable = entity.renewAvailable ?? false
        realmEntity.osagoRenewStatus.value = entity.osagoRenewStatus.map { $0.rawValue }
        realmEntity.renewUrl = entity.renewUrl?.absoluteString
        realmEntity.renewInsuranceId = entity.renewInsuranceId
        try entity.fieldGroupList.forEach {
            realmEntity.fieldGroupList.append(try fieldGroupTransformer.transform(entity: $0))
        }
        realmEntity.insuredObjectTitle = entity.insuredObjectTitle
        realmEntity.emergencyPhone = try phoneTransformer.transform(entity: entity.emergencyPhone)
        entity.sosActivities.forEach {
            realmEntity.sosActivities.append($0.rawValue)
        }
        (entity.clinicIds ?? []).forEach {
            realmEntity.clinicIds.append($0)
        }
        realmEntity.accessClinicPhone = entity.accessClinicPhone ?? false
        realmEntity.type = entity.type.rawValue
        realmEntity.archiveDate = entity.archiveDate
        realmEntity.pdfURL = entity.pdfURL?.absoluteString
        realmEntity.helpURL = entity.helpURL?.absoluteString
        realmEntity.helpType = entity.helpType?.rawValue
        realmEntity.passbookAvailable = entity.passbookAvailable ?? false
        realmEntity.passbookAvailableOnline = entity.passbookAvailableOnline ?? false
        realmEntity.insuranceIdOuter = entity.insuranceIdOuter
        realmEntity.mobileDeeplinkID = entity.mobileDeeplinkID
        realmEntity.telemedicine = entity.telemedicine
        realmEntity.isInsurer = entity.isInsurer
        realmEntity.isChild.value = entity.isChild
        realmEntity.company = entity.company.map { $0.rawValue }
        realmEntity.kidsDoctorPhone = try entity.kidsDoctorPhone.map(phoneTransformer.transform(entity:))
        try entity.bills.forEach {
            realmEntity.bills.append(try billsTransformer.transform(entity: $0))
        }
        realmEntity.shouldShowBills = entity.shouldShowBills
        realmEntity.hasUnpaidBills = entity.hasUnpaidBills
        realmEntity.shouldShowGuaranteeLetters = entity.shouldShowGuaranteeLetters
        realmEntity.isFranchiseTransitionAvailable = entity.isFranchiseTransitionAvailable
        entity.servicesList.forEach {
            realmEntity.servicesList.append($0.rawValue)
        }
        return realmEntity
    }

    override func transform(object: RealmEntity) throws -> T {
        guard let object = object as? RealmEntityType else { throw RealmError.typeMismatch }

        guard !object.id.isEmpty else { throw RealmError.typeMismatch }
        guard let emergencyPhone = object.emergencyPhone else { throw RealmError.typeMismatch }
        guard let type = Insurance.Kind(rawValue: object.type) else { throw RealmError.typeMismatch }
        guard let helpType = Insurance.HelpType(rawValue: object.helpType ?? Insurance.HelpType.none.rawValue) else { throw RealmError.typeMismatch }

        var sosActivities: [SOSActivity] = []
        try object.sosActivities.forEach {
            guard let sosActivity = SOSActivity(rawValue: $0) else { throw RealmError.typeMismatch }

            sosActivities.append(sosActivity)
        }
        let entity = EntityType(
            id: object.id,
            title: object.title,
            contractNumber: object.contractNumber,
            startDate: object.startDate,
            endDate: object.endDate,
            description: object.objectDescription,
            insurancePremium: object.insurancePremium,
            ownerParticipants: try object.ownerParticipants.map(participantTransformer.transform(object:)),
            insurerParticipants: try object.insurerParticipants.map(participantTransformer.transform(object:)),
            insuredParticipants: try object.insuredParticipants.map(participantTransformer.transform(object:)),
            benefitParticipants: try object.benefitParticipants.map(participantTransformer.transform(object:)),
            drivers: try object.drivers.map(participantTransformer.transform(object:)),
            vehicle: try object.vehicle.map(vehicleTransformer.transform(object:)),
            tripSegments: try object.tripSegments.map(tripTransformer.transform(object:)),
            productId: object.productId,
            renewAvailable: object.renewAvailable,
            osagoRenewStatus: object.osagoRenewStatus.value.flatMap(Insurance.OsagoRenewStatusKind.init),
            renewUrl: object.renewUrl.flatMap(URL.init(string:)),
            renewInsuranceId: object.renewInsuranceId,
            fieldGroupList: try object.fieldGroupList.map(fieldGroupTransformer.transform(object:)),
            insuredObjectTitle: object.insuredObjectTitle,
            emergencyPhone: try phoneTransformer.transform(object: emergencyPhone),
            sosActivities: sosActivities,
            clinicIds: Array(object.clinicIds),
            accessClinicPhone: object.accessClinicPhone,
            type: type,
            archiveDate: object.archiveDate,
            pdfURL: object.pdfURL.flatMap(URL.init(string:)),
            helpURL: object.helpURL.flatMap(URL.init(string:)),
            helpType: helpType,
            passbookAvailable: object.passbookAvailable,
            passbookAvailableOnline: object.passbookAvailableOnline,
            insuranceIdOuter: object.insuranceIdOuter,
            mobileDeeplinkID: object.mobileDeeplinkID,
            telemedicine: object.telemedicine,
            isInsurer: object.isInsurer,
            isChild: object.isChild.value,
            company: object.company.flatMap { Insurance.Company(rawValue: $0) },
            kidsDoctorPhone: try object.kidsDoctorPhone.map(phoneTransformer.transform(object:)),
            bills: try object.bills.map(billsTransformer.transform(object:)),
            shouldShowBills: object.shouldShowBills,
            hasUnpaidBills: object.hasUnpaidBills,
            shouldShowGuaranteeLetters: object.shouldShowGuaranteeLetters,
            isFranchiseTransitionAvailable: object.isFranchiseTransitionAvailable,
            servicesList: object.servicesList.compactMap { Insurance.ServiceAvailabilty(rawValue: $0) }
        )
        if let entity = entity as? T {
            return entity
        } else {
            throw RealmError.typeMismatch
        }
    }
}
