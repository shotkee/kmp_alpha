//
//  RestInsuranceBillPaymentService.swift
//  AlfaStrah
//
//  Created by Vitaly Trofimov on 22.12.2021.
//  Copyright © 2021 Touch Instinct. All rights reserved.
//

import Legacy

class RestInsuranceBillPaymentService: InsuranceBillPaymentService {
    private let rest: FullRestClient

    init(rest: FullRestClient) {
        self.rest = rest
    }

    // MARK: - URL Rest

    func paymentUrl(
        insuranceId: String,
        insuranceBillIds: [Int],
        email: String,
        phone: String,
        completion: @escaping (Result<InsuranceBillPaymentPageInfo, AlfastrahError>) -> Void
    ) {
        let request = InsuranceBillPaymentURLRequest(
            insuranceId: insuranceId,
            billIds: insuranceBillIds,
            email: email,
            phone: phone
        )

        rest.create(
            path: "/api/insurances/dms/bills/pay",
            id: nil,
            object: request,
            headers: [:],
            requestTransformer: InsuranceBillPaymentURLRequestTransformer(),
            responseTransformer: ResponseTransformer(transformer: InsuranceBillPaymentPageInfoTransformer()),
            completion: mapCompletion(completion)
        )
    }
    
    func bill(
        insuranceId: String,
        billId: Int,
        completion: @escaping (Result<InsuranceBill, AlfastrahError>) -> Void
    ) {
        rest.read(
            path: "/api/insurances/dms/bills/single",
            id: nil,
            parameters: [
                "insurance_id": insuranceId,
                "bill_id": "\(billId)",
            ],
            headers: [:],
            responseTransformer: ResponseTransformer(
                key: "bill",
                transformer: InsuranceBillTransformer()
            ),
            completion: mapCompletion { result in
                completion(result)
            }
        )
    }
}
