//
//  InsuranceBillPaymentService.swift
//  AlfaStrah
//
//  Created by Vitaly Trofimov on 22.12.2021.
//  Copyright © 2021 Touch Instinct. All rights reserved.
//

protocol InsuranceBillPaymentService {
    func paymentUrl(
        insuranceId: String,
        insuranceBillIds: [Int],
        email: String,
        phone: String,
        completion: @escaping (Result<InsuranceBillPaymentPageInfo, AlfastrahError>) -> Void
    )
    
    func bill(
        insuranceId: String,
        billId: Int,
        completion: @escaping (Result<InsuranceBill, AlfastrahError>) -> Void
    )
}
