//
//  InsuranceSearchPolicyRequest
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 15/12/2018.
//  Copyright © 2018 Redmadrobot. All rights reserved.
//

// sourcery: transformer
/// InsuranceSearchPolicyRequest
/// https://redmadrobot.atlassian.net/wiki/spaces/AL/pages/217546825/21+InsuranceSearchPolicyRequest
struct InsuranceSearchPolicyRequest {
    // sourcery: transformer = IdTransformer<Any>()
    var id: String

    // sourcery: transformer.name = "insurance_number"
    var insuranceNumber: String

    // sourcery: transformer.name = "image_url", transformer = "UrlTransformer<Any>()"
    var imageURL: URL?

    // sourcery: transformer = "DateTransformer<Any>(format: "yyyy-mm-dd", locale: AppLocale.currentLocale)"
    // sourcery: transformer.name = "issue_date"
    var issueDate: Date?

    // sourcery: transformer = "DateTransformer<Any>(format: "yyyy-mm-dd HH:mm:ss", locale: AppLocale.currentLocale)"
    // sourcery: transformer.name = "request_datetime"
    var requestDate: Date?

    var state: InsuranceSearchPolicyRequest.State

    // sourcery: transformer = "DateTransformer<Any>(format: "yyyy-MM-dd", locale: AppLocale.currentLocale)"
    // sourcery: transformer.name = "planned_date"
    var plannedDate: Date?

    // sourcery: transformer = "DateTransformer<Any>(format: "yyyy-mm-dd", locale: AppLocale.currentLocale)"
    // sourcery: transformer.name = "planned_date_min"
    var plannedDateMin: Date?

    // sourcery: transformer.name = "type", transformer = IdTransformer<Any>()
    var productId: String

    // sourcery: enumTransformer, enumTransformer.type = "String"
    enum State {
        // sourcery: enumTransformer.value = "UNCONFIRMED", defaultCase
        case unconfirmed
        // sourcery: enumTransformer.value = "CONFIRMED"
        case confirmed
        // sourcery: enumTransformer.value = "CONFIRMED_DELAY"
        case confirmedWithDelay
        // sourcery: enumTransformer.value = "PROCESSING"
        case processing
        // sourcery: enumTransformer.value = "NUMBER_WRONG"
        case wrongNumber
        // sourcery: enumTransformer.value = "POLICY_NOT_FOUND"
        case notFound
        // sourcery: enumTransformer.value = "PERSON_NOT_FOUND"
        case personNotFound
    }
}
