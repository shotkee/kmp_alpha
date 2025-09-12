//
//  DoctorCallBDUI.swift
//  AlfaStrah
//
//  Created by vit on 29.08.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

// sourcery: transformer
struct DoctorCallBDUI {
	// sourcery: transformer.name = "fullNameInsured"
	let userFullname: String
	
	// sourcery: transformer.name = "contactPhone"
	var userPhoneNumber: String
	
	// sourcery: transformer.name = "visitDateList"
	let visitDates: [VisitDateBDUI]

	// sourcery: transformer.name = "specialist"
	let doctorSpeciality: String
	
	// sourcery: transformer.name = "distanceType"
	let distanceType: [String]
	
	// sourcery: transformer.name = "childPopupData"
	let childDoctorBanner: BannerDataBDUI?
	
	// sourcery: transformer.name = "callInformation"
	let additionalInfo: String?

	// sourcery: transformer.name = "isChild"
	let forChild: Bool
	
	// sourcery: transformer.name = "insuranceId"
	let insuranceId: Int
	
	// sourcery: transformer.name = "sickLeaveRequired"
	let medicalLeaveAnswers: [String]
}

// sourcery: transformer
struct VisitDateBDUI {
	// sourcery: transformer.name = "date", transformer = "DateTransformer<Any>(format: "yyyy-MM-dd", locale: AppLocale.currentLocale)"
	let date: Date
	
	// sourcery: transformer.name = "showDate"
	let dateString: String
}

// sourcery: transformer
struct BannerDataBDUI {
	// sourcery: transformer.name = "title"
	let title: String
	
	// sourcery: transformer.name = "text"
	let text: String
	
	// sourcery: transformer.name = "button_text"
	let buttonTitle: String
}
