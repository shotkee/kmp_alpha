//
//  InsuranceProgramService.swift
//  AlfaStrah
//
//  Created by mac on 19.11.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

import Legacy

protocol InsuranceProgramService {
    func getHelpBlocks(insuranceId: String, completion: @escaping (Result<[InsuranceProgramHelpBlock], AlfastrahError>) -> Void)
}
