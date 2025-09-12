//
//  InsuranceBillPaymentPageInfo.swift
//  AlfaStrah
//
//  Created by Vitaly Trofimov on 23.12.2021.
//  Copyright © 2021 Touch Instinct. All rights reserved.
//

import Foundation

// sourcery: transformer
struct InsuranceBillPaymentPageInfo {
    // sourcery: transformer.name = "payment_link", transformer = "UrlTransformer<Any>()"
    let url: URL

    // sourcery: transformer.name = "success_url_part"
    let successString: String

    // sourcery: transformer.name = "fail_url_part"
    let failureString: String
}
