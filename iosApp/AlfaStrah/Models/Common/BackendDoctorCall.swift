//
//  BackendDoctorCall.swift
//  AlfaStrah
//
//  Created by vit on 02.11.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

import Foundation

// sourcery: transformer
struct BackendDoctorCall {
    // sourcery: transformer.name = "is_child"
    let forChild: Bool
    
    // sourcery: transformer.name = "child_popup_data"
    let childDoctorBanner: BackendBannerData?
    
    // sourcery: transformer.name = "full_name_insured"
    let userFullname: String
    
    // sourcery: transformer.name = "contact_phone"
    var userPhoneNumber: String
    
    // sourcery: transformer.name = "specialist"
    let doctorSpeciality: String

    // sourcery: transformer.name = "distance_type"
    let distanceType: String
    
    // sourcery: transformer.name = "distance_title"
    let distanceTitle: String?
    
    // sourcery: transformer.name = "sick_leave_required"
    let medicalLeaveIsRequiredTitle: String
    
    // sourcery: transformer.name = "visit_date_list"
    let visitDates: [BackendVisitDate]
    
    // sourcery: transformer.name = "call_information"
    let additionalInfo: String?
}

// sourcery: transformer
struct BackendVisitDate {
    // sourcery: transformer.name = "date", transformer = "DateTransformer<Any>(format: "yyyy-MM-dd", locale: AppLocale.currentLocale)"
    let date: Date
    
    // sourcery: transformer.name = "show_date"
    let dateString: String
}

// sourcery: transformer
struct BackendBannerData {
    // sourcery: transformer.name = "title"
    let title: String
    
    // sourcery: transformer.name = "text"
    let text: String
    
    // sourcery: transformer.name = "button_text"
    let buttonTitle: String
}
