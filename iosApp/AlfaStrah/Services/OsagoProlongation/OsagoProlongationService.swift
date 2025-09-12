//
//  OsagoProlongationService.swift
//  AlfaStrah
//
//  Created by Nikita Omelchenko on 19.02.2021.
//  Copyright © 2021 Redmadrobot. All rights reserved.
//

import Legacy

protocol OsagoProlongationService {
    func insurancesOsagoProlongationCalcRequest(
        insuranceId: String,
        completion: @escaping (Result<OsagoProlongation, AlfastrahError>) -> Void
    ) -> NetworkTask

    func insurancesOsagoProlongationChangeRequest(
        changeRequest: OsagoProlongationChangeRequest,
        completion: @escaping (Result<Void, AlfastrahError>) -> Void
    )

    func insurancesOsagoProlongationDeeplinkRequest(
        insuranceId: String,
        agreedToPersonalDataPolicy: Bool,
        completion: @escaping (Result<OsagoProlongationDeeplink, AlfastrahError>) -> Void
    )

    func insurancesOsagoProlongationProgramRequest(
        insuranceID: String,
        completion: @escaping (Result<OsagoProlongationURLs, AlfastrahError>) -> Void
    ) -> NetworkTask
}
