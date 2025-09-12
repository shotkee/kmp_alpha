//
// RealmAppNotificationTransformer
// AlfaStrah
//
// Created by Eugene Egorov on 04 February 2019.
// Copyright (c) 2019 Redmadrobot. All rights reserved.
//

import RealmSwift

class RealmAppNotificationTransformer<T: Entity>: RealmTransformer<T> {
    typealias EntityType = AppNotification
    typealias RealmEntityType = RealmAppNotification

    private let phoneTransformer: RealmPhoneTransformer<Phone> = .init()
    private let fieldTransformer: RealmAppNotificationFieldTransformer<AppNotificationField> = .init()
    private let stoaTransformer: RealmStoaTransformer<Stoa> = .init()

    override var objectType: RealmEntity.Type {
        RealmEntityType.self
    }

    override func transform(entity: T) throws -> RealmEntity {
        guard let entity = entity as? EntityType else { throw RealmError.typeMismatch }

        let realmEntity = RealmEntityType()
        realmEntity.id = entity.id
        realmEntity.type = entity.type.rawValue
        realmEntity.title = entity.title
        realmEntity.annotation = entity.annotation
        realmEntity.fullText = entity.fullText
        realmEntity.date = entity.date
        realmEntity.important = entity.important
        realmEntity.insuranceId = entity.insuranceId
        realmEntity.stoa = try entity.stoa.map(stoaTransformer.transform(entity:))
        realmEntity.offlineAppointmentId = entity.offlineAppointmentId
        try (entity.fieldList ?? []).forEach {
            realmEntity.fieldList.append(try fieldTransformer.transform(entity: $0))
        }
        realmEntity.phone = try entity.phone.map(phoneTransformer.transform(entity:))
        realmEntity.userRequestDate = entity.userRequestDate
        realmEntity.eventNumber = entity.eventNumber
        realmEntity.onlineAppointmentId = entity.onlineAppointmentId
        realmEntity.isRead = entity.isRead
        realmEntity.url = entity.url
        realmEntity.target = entity.target.rawValue
        return realmEntity
    }

    override func transform(object: RealmEntity) throws -> T {
        guard let object = object as? RealmEntityType else { throw RealmError.typeMismatch }

        guard !object.id.isEmpty else { throw RealmError.typeMismatch }
        guard
            let type = AppNotification.Kind(rawValue: object.type),
            let target = DeeplinkDestination(rawValue: object.target)
        else { throw RealmError.typeMismatch }

        let entity = EntityType(
            id: object.id,
            type: type,
            title: object.title,
            annotation: object.annotation,
            fullText: object.fullText,
            date: object.date,
            important: object.important,
            insuranceId: object.insuranceId,
            stoa: try object.stoa.map(stoaTransformer.transform(object:)),
            offlineAppointmentId: object.offlineAppointmentId,
            fieldList: try object.fieldList.map(fieldTransformer.transform(object:)),
            phone: try object.phone.map(phoneTransformer.transform(object:)),
            userRequestDate: object.userRequestDate,
            eventNumber: object.eventNumber,
            onlineAppointmentId: object.onlineAppointmentId,
            isRead: object.isRead,
            url: object.url,
            target: target
        )
        if let entity = entity as? T {
            return entity
        } else {
            throw RealmError.typeMismatch
        }
    }
}
