//
//  InsuranceBill.swift
//  AlfaStrah
//
//  Created by Vyacheslav Shakaev on 21.12.2021.
//  Copyright © 2021 Touch Instinct. All rights reserved.
//

import Foundation

// sourcery: transformer
struct InsuranceBill: Entity, Equatable {
    let id: Int

    // sourcery: transformer.name = "user_name"
    let recipientName: String

    // sourcery: transformer.name = "bill_number"
    let number: String

    // sourcery: transformer.name = "bill_info"
    let info: String

    // sourcery: transformer.name = "status"
    let statusText: String

    // sourcery: transformer.name = "date"
    // sourcery: transformer = "DateTransformer<Any>(format: "yyyy-MM-dd HH:mm:ss", locale: AppLocale.currentLocale)"
    let creationDate: Date

    // sourcery: transformer.name = "amount"
    let moneyAmount: Double

    let description: String

    // sourcery: transformer.name = "is_payment_needed"
    let shouldBePaidOff: Bool

    // sourcery: transformer.name = "can_be_group_paid"
    let canBePaidInGroup: Bool

    // sourcery: transformer.name = "can_create_not_agreed"
    let canSubmitDisagreement: Bool

    // sourcery: transformer.name = "date_paid"
    // sourcery: transformer = "DateTransformer<Any>(format: "dd/MM/yyyy", locale: AppLocale.currentLocale)"
    let paymentDate: Date?

    // sourcery: transformer.name = "highlighted_type"
    let highlighting: Highlighting

    // sourcery: enumTransformer
    enum Highlighting: Int {
        // sourcery: defaultCase
        case noHighlighting = 0
        case highlightWithRed = 1
    }
}
