//
//  RealmInsuranceShort.swift
//  AlfaStrah
//
//  Created by Evgeny Ivanov on 10/04/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import Foundation
import RealmSwift

class RealmInsuranceShort: RealmEntity {
    @objc dynamic var id: String = ""
    @objc dynamic var title: String = ""
    @objc dynamic var insuranceDescription: String = ""
    @objc dynamic var renewAvailable: Bool = false
    @objc dynamic var startDate: Date = Date()
    @objc dynamic var endDate: Date = Date()
    dynamic var renewType: RealmProperty<Int?> = {
        let property = RealmProperty<Int?>()
        property.value = 1
        return property
    }()
    dynamic var eventReportType: RealmProperty<Int?> = .init()
    @objc dynamic var label: String?
    @objc dynamic var type: Int = 1
    @objc dynamic var warning: String?
	@objc dynamic var render: RealmInsuranceRender?
	
    @objc dynamic var onboardingWasShown: Bool = false
	@objc dynamic var analyticsInsuranceProfile: RealmAnalyticsInsuranceProfile?
}
