//
//  RealmInsuranceShortTransformer.swift
//  AlfaStrah
//
//  Created by Evgeny Ivanov on 12/04/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import RealmSwift

class RealmInsuranceShortTransformer<T: Entity>: RealmTransformer<T> {
    typealias EntityType = InsuranceShort
    typealias RealmEntityType = RealmInsuranceShort
	
	private let renderTransformer: RealmInsuranceRenderTransformer<InsuranceRender> = .init()
	private let analyticsInsuranceProfileTransformer: RealmAnalyticsInsuranceProfileTransformer<AnalyticsInsuranceProfile> = .init()

    override var objectType: RealmEntity.Type {
        RealmEntityType.self
    }

    override func transform(entity: T) throws -> RealmEntity {
        guard let entity = entity as? EntityType
        else { throw RealmError.typeMismatch }

        let realmEntity = RealmEntityType()
        realmEntity.id = entity.id
        realmEntity.title = entity.title
        realmEntity.startDate = entity.startDate
        realmEntity.endDate = entity.endDate
        realmEntity.renewAvailable = entity.renewAvailable
        realmEntity.eventReportType.value = entity.eventReportType.map { $0.rawValue }
        realmEntity.renewType.value = entity.renewType?.rawValue
        realmEntity.insuranceDescription = entity.description ?? ""
        realmEntity.label = entity.label
        realmEntity.type = entity.type.rawValue
        realmEntity.warning = entity.warning
		realmEntity.render = try entity.render.map(renderTransformer.transform(entity:))
		realmEntity.analyticsInsuranceProfile = try entity.analyticsInsuranceProfile.map(analyticsInsuranceProfileTransformer.transform(entity:))
		
        return realmEntity
    }

    override func transform(object: RealmEntity) throws -> T {
        guard let object = object as? RealmEntityType
        else { throw RealmError.typeMismatch }

        guard
            !object.id.isEmpty,
            let type = InsuranceShort.Kind(rawValue: object.type)
        else { throw RealmError.typeMismatch }

        let entity = EntityType(
            id: object.id,
            title: object.title,
            startDate: object.startDate,
            endDate: object.endDate,
            renewAvailable: object.renewAvailable,
            renewType: object.renewType.value.flatMap { InsuranceShort.RenewType(rawValue: $0) },
            description: object.insuranceDescription,
            eventReportType: object.eventReportType.value.flatMap(InsuranceShort.EventReportType.init),
            label: object.label,
            type: type,
            warning: object.warning,
			render: try object.render.map(renderTransformer.transform(object:)),
			analyticsInsuranceProfile: try object.analyticsInsuranceProfile.map(analyticsInsuranceProfileTransformer.transform(object:))
        )
        
        if let entity = entity as? T {
            return entity
        } else {
            throw RealmError.typeMismatch
        }
    }
}
