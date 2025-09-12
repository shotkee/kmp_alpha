//
//  EventReportAccident.swift
//  AlfaStrah
//
//  Created by Amir Nuriev on 6/4/19.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

// sourcery: transformer
struct EventReportAccident {
    // sourcery: transformer = IdTransformer<Any>()
    var id: String

    var title: String

    // sourcery: transformer = IdTransformer<Any>()
    var number: String

    // sourcery: transformer.name = "date", transformer = "DateTransformer<Any>(format: "yyyy-MM-dd", locale: AppLocale.currentLocale)"
    var createDate: Date

    // sourcery: transformer.name = "insurance_id", transformer = IdTransformer<Any>()
    var insuranceId: String

    // sourcery: enumTransformer, enumTransformer.type = "String"
    enum StatusKind {
        // sourcery: enumTransformer.value = "new", defaultCase
        case new
        // sourcery: enumTransformer.value = "in-work"
        case inWork
        // sourcery: enumTransformer.value = "request-documents"
        case requestDocuments
        // sourcery: enumTransformer.value = "payout"
        case payout
        // sourcery: enumTransformer.value = "reject"
        case reject

        var icon: UIImage? {
            switch self {
                case .reject:
                    return UIImage(named: "icon-close-thin-small")
                case .payout:
                    return UIImage(named: "icon-checkmark-red-small")
                case .new, .inWork, .requestDocuments:
                    return UIImage(named: "icon-clock")
            }
        }
    }

    // sourcery: transformer.name = "status_id"
    var statusKind: EventReportAccident.StatusKind

    var status: String

    // sourcery: transformer.name = "status_description"
    var statusDescription: String

    var event: String

    // sourcery: transformer.name = "photo_cnt"
    var photoUploaded: Int

    // sourcery: transformer.name = "is_opened"
    var isOpened: Bool

    // sourcery: transformer.name = "allow_attach_optional"
    var canAddPhotos: Bool

    // sourcery: transformer.name = "allow_change_payout"
    var canEditPayout: Bool

    var bik: String?

    // sourcery: transformer.name = "account_number"
    var accountNumber: String?
}
