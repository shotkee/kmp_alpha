//
//  DmsCostRecoveryApplicationRequest.swift
//  AlfaStrah
//
//  Created by vit on 06.02.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

// sourcery: transformer
struct DmsCostRecoveryApplicationRequestParameters {
    // sourcery: transformer.name = "insurance_id"
    var insuranceId: String

    // sourcery: transformer.name = "request"
    var request: DmsCostRecoveryApplicationRequest
}

// sourcery: transformer
struct DmsCostRecoveryApplicationEditParameters {
    // sourcery: transformer.name = "request_id"
    var applicationId: String
    
    // sourcery: transformer.name = "request"
    var request: DmsCostRecoveryApplicationRequest
}

// sourcery: transformer
struct DmsCostRecoveryApplicationRequest {
    // sourcery: transformer.name = "insurer"
    let applicantPersonalInfo: DmsCostRecoveryApplicantPersonalInfo
    // sourcery: transformer.name = "passport"
    let passport: DmsCostRecoveryPassport
    // sourcery: transformer.name = "refund_requisites"
    let requisites: DmsCostRecoveryRequisites
    // sourcery: transformer.name = "additional_personal_info"
    let additionalInfo: DmsCostRecoveryAdditionalInfo
    // sourcery: transformer.name = "insured"
    let insuredPersonInfo: DmsCostRecoveryInsuredPerson
    // sourcery: transformer.name = "additional_service_info"
    let insuranceEventInfo: DmsCostRecoveryInsuranceEventApplicationInfo
}

// sourcery: transformer
struct DmsCostRecoveryPassport {
    // sourcery: transformer.name = "series"
    let series: String
    // sourcery: transformer.name = "number"
    let number: String
    // sourcery: transformer.name = "issue_place"
    let issuer: String
    // sourcery: transformer.name = "issue_date", transformer = "DateTransformer<Any>(format: "yyyy-MM-dd")"
    let issueDate: Date
    // sourcery: transformer.name = "birth_place"
    let birthPlace: String
    // sourcery: transformer.name = "citizenship"
    let citizenship: String
}

// sourcery: transformer
struct DmsCostRecoveryRequisites {
    // sourcery: transformer.name = "bank"
    let bank: DmsCostRecoveryBank
    // sourcery: transformer.name = "account_number"
    let accountNumber: String
}

// sourcery: transformer
struct DmsCostRecoveryAdditionalInfo {
    // sourcery: enumTransformer, enumTransformer.type = "String"
    enum СitizenshipType {
        // sourcery: enumTransformer.value = "citizen"
        case citizen
        // sourcery: enumTransformer.value = "immigrant"
        case nonResident
    }
    
    // sourcery: transformer.name = "citizen_type"
    let citizenship: DmsCostRecoveryAdditionalInfo.СitizenshipType
    // sourcery: transformer.name = "snils_number"
    let snils: String?
    // sourcery: transformer.name = "inn_number"
    let inn: String?
    // sourcery: transformer.name = "migration_card_number"
    let migrationCardNumber: String?
    // sourcery: transformer.name = "residential_address"
    let residentialAddress: String?
}

// sourcery: transformer
struct DmsCostRecoveryInsuranceEventApplicationInfo {
    // sourcery: transformer.name = "country"
    let country: String
    // sourcery: transformer.name = "date", transformer = "DateTransformer<Any>(format: "yyyy-MM-dd")"
    let date: Date
    // sourcery: transformer.name = "service"
    let medicalService: String
    // sourcery: transformer.name = "reason"
    let reason: String
    // sourcery: transformer.name = "cost"
    let expensesAmount: String
    // sourcery: transformer.name = "currency"
    let currency: String
}
