//
//  InsuranceShort.swift
//  AlfaStrah
//
//  Created by Eugene Ivanov on 27/03/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

// sourcery: transformer
struct InsuranceShort: Entity {
    // sourcery: transformer = IdTransformer<Any>()
    var id: String

    var title: String

    // sourcery: transformer.name = "start_date"
    // sourcery: transformer = "DateTransformer<Any>(format: "yyyy-MM-dd HH:mm:ss", locale: AppLocale.currentLocale)"
    var startDate: Date

    // sourcery: transformer.name = "end_date"
    // sourcery: transformer = "DateTransformer<Any>(format: "yyyy-MM-dd HH:mm:ss", locale: AppLocale.currentLocale)"
    var endDate: Date

    // sourcery: transformer.name = "renew_available"
    var renewAvailable: Bool

    // sourcery: transformer.name = "renew_type"
    var renewType: InsuranceShort.RenewType?

    // sourcery: enumTransformer
    enum RenewType: Int {
        // sourcery: defaultCase
        case unsupported = 0
        case url = 1
        case osago = 2
        case kasko = 3
        case remont = 4
        case kindNeighbors = 5
    }

    var description: String?

    // sourcery: transformer.name = "event_report_type"
    var eventReportType: InsuranceShort.EventReportType?

	// sourcery: transformer.name = "label"
    var label: String?

	// sourcery: transformer.name = "type"
    var type: InsuranceShort.Kind

	// sourcery: transformer.name = "warning"
    var warning: String?
	
	// sourcery: transformer.name = "render"
	var render: InsuranceRender?

    // sourcery: enumTransformer
    enum EventReportType: Int {
        // sourcery: defaultCase
        case unsupported = 0
        case kasko = 1
        case osago = 2
        case doctor = 3
        case passenger = 4
        case vzr = 5
    }

    // sourcery: enumTransformer
    enum Kind: Int {
        // sourcery: defaultCase
        case unsupported = 0
        case kasko = 1
        case osago = 2
        case dms = 3
        case vzr = 4
        case property = 5
        case passengers = 6
        case life = 7
        case accident = 8
        case kaskoOnOff = 9
        case vzrOnOff = 10
        case flatOnOff = 11
    }
	
	// sourcery: transformer.name = "dms"
	let analyticsInsuranceProfile: AnalyticsInsuranceProfile?
	
	var authorizedAnalyticsIsAllowed: Bool {
		if analyticsInsuranceProfile?.insurerFirstname != nil,
		   analyticsInsuranceProfile?.groupName != nil {
			return true
		}
		
		return false
	}
	
	var analyticsUserProfileProperties: [String: String] {
		if let insurerFirstname = analyticsInsuranceProfile?.insurerFirstname,
		   let groupName = analyticsInsuranceProfile?.groupName {
			return [
				AnalyticsParam.Profile.insurerFirstname: insurerFirstname,
				AnalyticsParam.Profile.insuranceGroupName: groupName
			]
		}
		
		return [:]
	}
}
