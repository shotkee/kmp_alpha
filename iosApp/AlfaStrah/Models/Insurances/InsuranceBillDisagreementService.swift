//
//  InsuranceBillDisagreementService.swift
//  AlfaStrah
//
//  Created by Vyacheslav Shakaev on 14.06.2022.
//  Copyright © 2022 Touch Instinct. All rights reserved.
//

import Foundation

// sourcery: transformer
struct InsuranceBillDisagreementService: Entity
{
    let id: Int

    // sourcery: transformer.name = "corp_full_name"
    let clinicName: String

    // sourcery: transformer.name = "mt_date"
    // sourcery: transformer = "DateTransformer<Any>(format: "yyyy-MM-dd", locale: AppLocale.currentLocale)"
    let date: Date

    // sourcery: transformer.name = "service_name"
    let serviceName: String

    let quantity: Double

    // sourcery: transformer.name = "sum_franch"
    let sumWithFranchise: Double

    // sourcery: transformer.name = "franchise"
    let franchisePercentage: String

    // sourcery: transformer.name = "to_pay_value"
    let paymentAmount: Double
}
