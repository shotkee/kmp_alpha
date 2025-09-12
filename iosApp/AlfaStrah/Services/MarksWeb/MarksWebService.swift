//
//  MarksWebService.swift
//  AlfaStrah
//
//  Created by vit on 19.07.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

protocol MarksWebService {
    func manageSubscriptionUrl(insuranceId: String, completion: @escaping (Result<URL, AlfastrahError>) -> Void)
    func appointBeneficiaryUrl(insuranceId: String, completion: @escaping (Result<URL, AlfastrahError>) -> Void)
    func editInsuranceAgreementUrl(insuranceId: String, completion: @escaping (Result<URL, AlfastrahError>) -> Void)
}
