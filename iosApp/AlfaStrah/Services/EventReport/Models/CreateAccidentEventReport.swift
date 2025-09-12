//
//  CreateAccidentEventReport
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 29.10.2020.
//  Copyright © 2020 Redmadrobot. All rights reserved.
//

// sourcery: transformer
struct CreateAccidentEventReport {
    // sourcery: transformer.name = "insurance_id"
    var insuranceId: String
    // sourcery: transformer.name = "full_description"
    var fullDescription: String
    // sourcery: transformer.name = "document_count"
    var documentCount: Int
    // sourcery: transformer.name = "claim_date"
    // sourcery: transformer = "DateTransformer<Any>(format: "yyyy-MM-dd HH:mm:ss", locale: AppLocale.currentLocale)"
    var claimDate: Date
    // sourcery: transformer = "DateTransformer<Any>(format: "xxx", locale: AppLocale.currentLocale)"
    var timezone: Date
    var beneficiary: String
    // sourcery: transformer.name = "passport_seria"
    var passportSeria: String
    // sourcery: transformer.name = "passport_number"
    var passportNumber: String
    var bik: String
    // sourcery: transformer.name = "account_number"
    var accountNumber: String
}
