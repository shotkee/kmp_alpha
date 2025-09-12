//
//  DmsCostRecoveryResult.swift
//  AlfaStrah
//
//  Created by vit on 24.01.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

// sourcery: transformer
struct DmsCostRecoveryData {
    // sourcery: transformer.name = "plan_info"
    let instruction: DmsCostRecoveryInstruction
    // sourcery: transformer.name = "insurer"
    let applicantPersonalInfo: DmsCostRecoveryApplicantPersonalInfo
    // sourcery: transformer.name = "insured_list"
    let insuredPersons: [DmsCostRecoveryInsuredPerson]
    // sourcery: transformer.name = "medical_service_list"
    let medicalServices: [DmsCostRecoveryMedicalService]
    // sourcery: transformer.name = "currency_list"
    let currencies: [DmsCostRecoveryCurrency]
    // sourcery: transformer.name = "popular_bank_list"
    let popularBanks: [DmsCostRecoveryBank]
    // sourcery: transformer.name = "files_info"
    let documentsInfo: DmsCostRecoveryDocumentsInfo
    // sourcery: transformer.name = "passport"
    let passport: DmsCostRecoveryPassport?
    // sourcery: transformer.name = "refund_requisites"
    let requisites: DmsCostRecoveryRequisites?
    // sourcery: transformer.name = "additional_personal_info"
    let additionalInfo: DmsCostRecoveryAdditionalInfo?
}

// sourcery: transformer
struct DmsCostRecoveryInstruction {
    // sourcery: transformer.name = "details"
    let insurancePlan: DmsCostRecoveryInsurancePlan?
    // sourcery: transformer.name = "step_list"
    let conditions: [DmsCostRecoveryCondition]
    // sourcery: transformer.name = "what_to_do_info"
    let notice: String?
}

// sourcery: transformer
struct DmsCostRecoveryInsurancePlan {
    // sourcery: transformer.name = "title"
    let title: String
    // sourcery: transformer.name = "description"
    let description: String
    // sourcery: transformer.name = "pdf_url"
    let urlPath: String
}

// sourcery: transformer
struct DmsCostRecoveryCondition {
    // sourcery: transformer.name = "number"
    let stepNumber: Int
    // sourcery: transformer.name = "title"
    let title: String
}

// sourcery: transformer
struct DmsCostRecoveryApplicantPersonalInfo {
    // sourcery: transformer.name = "full_name"
    let fullname: String
    // sourcery: transformer.name = "birthday", transformer = "DateTransformer<Any>(format: "yyyy-MM-dd")"
    let birthday: Date?
    // sourcery: transformer.name = "policy_number"
    let policyNumber: String
    // sourcery: transformer.name = "tab_number"
    let serviceNumber: String?
    // sourcery: transformer.name = "phone"
    let phone: Phone?
    // sourcery: transformer.name = "email"
    let email: String
}

// sourcery: transformer
struct DmsCostRecoveryInsuredPerson: Equatable {
    // sourcery: transformer.name = "full_name"
    let fullname: String
    // sourcery: transformer.name = "birthday", transformer = "DateTransformer<Any>(format: "yyyy-MM-dd")"
    let birthday: Date
    // sourcery: transformer.name = "policy_number"
    let policyNumber: String
    
    static func ==(lhs: DmsCostRecoveryInsuredPerson, rhs: DmsCostRecoveryInsuredPerson) -> Bool {
        return lhs.fullname == rhs.fullname && lhs.birthday == rhs.birthday && lhs.policyNumber == rhs.policyNumber
    }
}

// sourcery: transformer
struct DmsCostRecoveryMedicalService {
    // sourcery: transformer.name = "title"
    let title: String
    // sourcery: transformer.name = "value"
    let value: String
    // sourcery: transformer.name = "user_input_required"
    let isUserInputRequired: Bool
}

// sourcery: transformer
struct DmsCostRecoveryCurrency {
    // sourcery: transformer.name = "title"
    let title: String
    // sourcery: transformer.name = "value"
    let value: String
    // sourcery: transformer.name = "user_input_required"
    let isUserInputRequired: Bool
}

// sourcery: transformer
struct DmsCostRecoveryBank: Equatable {
    // sourcery: transformer.name = "title"
    let title: String
    // sourcery: transformer.name = "bik"
    let bik: String
    // sourcery: transformer.name = "corr_number"
    let correspondentAccount: String
    
    static func ==(lhs: DmsCostRecoveryBank, rhs: DmsCostRecoveryBank) -> Bool {
        return lhs.bik == rhs.bik
    }
}

// sourcery: transformer
struct DmsCostRecoveryDocumentsInfo {
    // sourcery: transformer.name = "file_type_list"
    let documentsByType: [DmsCostRecoveryDocumentsByType]
    // sourcery: transformer.name = "files_limit"
    let maximumUploadSize: Int
    // sourcery: transformer.name = "description"
    let description: String?
}

// sourcery: transformer
struct DmsCostRecoveryDocumentsByType: Equatable {
    // sourcery: transformer.name = "title"
    let title: String
    // sourcery: transformer.name = "file_group_list"
    let documentsLists: [DmsCostRecoveryDocumentsList]
    
    static func == (lhs: DmsCostRecoveryDocumentsByType, rhs: DmsCostRecoveryDocumentsByType) -> Bool {
        return lhs.title == rhs.title && lhs.documentsLists.count == rhs.documentsLists.count
    }
}

// sourcery: transformer
struct DmsCostRecoveryDocumentsList {
    // sourcery: transformer.name = "title"
    let fullTitle: String
    // sourcery: transformer.name = "label"
    let shortTitle: String
    // sourcery: transformer.name = "file_item_list"
    let documents: [DmsCostRecoveryDocument]
    
    var isRequired: Bool {
        get {
            guard documents.contains(where: {$0.isRequired == true })
            else { return false }
            
            return true
        }
    }
    
    static func ==(lhs: DmsCostRecoveryDocumentsList, rhs: DmsCostRecoveryDocumentsList) -> Bool {
        return
            lhs.fullTitle == rhs.fullTitle
            && lhs.shortTitle == rhs.shortTitle
            && lhs.isRequired == rhs.isRequired
    }
}

// sourcery: transformer
struct DmsCostRecoveryDocument: Equatable {
    // sourcery: transformer.name = "title"
    let title: String
    // sourcery: transformer.name = "value"
    let uploadName: String
    // sourcery: transformer.name = "is_required"
    let isRequired: Bool
    // sourcery: transformer.name = "is_multiselect_allowed"
    let isMultiselectAllowed: Bool
    
    static func ==(lhs: DmsCostRecoveryDocument, rhs: DmsCostRecoveryDocument) -> Bool {
        return
            lhs.title == rhs.title
            && lhs.uploadName == rhs.uploadName
            && lhs.isRequired == rhs.isRequired
            && lhs.isMultiselectAllowed == rhs.isMultiselectAllowed
    }
}
