//
//  FlatOnOffService.swift
//  AlfaStrah
//
//  Created by Peter Tretyakov on 30.03.2020.
//  Copyright © 2020 Redmadrobot. All rights reserved.
//

protocol FlatOnOffService {
    func insurances(_ completion: @escaping (Result<[FlatOnOffInsurance], AlfastrahError>) -> Void)
    func balance(insuranceId: String, completion: @escaping (Result<Int, AlfastrahError>) -> Void)
    func activations(insuranceId: String, completion: @escaping (Result<[FlatOnOffProtection], AlfastrahError>) -> Void)
    func activate(
        insuranceId: String,
        start: Date,
        finish: Date,
        completion: @escaping (Result<FlatOnOffProtectionCalculation, AlfastrahError>) -> Void
    )
    func confirmActivation(
        insuranceId: String,
        protectionId: String,
        completion: @escaping (Result<FlatOnOffConfirmActivationResponse, AlfastrahError>) -> Void
    )
    func packages(insuranceId: String, completion: @escaping (Result<[FlatOnOffPurchaseItem], AlfastrahError>) -> Void)
    func purchaseUrl(insuranceId: String, packageId: String, completion: @escaping (Result<URL, AlfastrahError>) -> Void)
    func landingURL(_ completion: @escaping (Result<URL, AlfastrahError>) -> Void)
}
