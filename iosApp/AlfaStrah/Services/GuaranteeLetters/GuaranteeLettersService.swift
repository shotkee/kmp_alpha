//
//  GuaranteeLettersService.swift
//  AlfaStrah
//
//  Created by Vyacheslav Shakaev on 08.04.2022.
//  Copyright © 2022 Touch Instinct. All rights reserved.
//

import Legacy

protocol GuaranteeLettersService {
    func guaranteeLetters(
        insuranceId: String,
        completion: @escaping (Result<[GuaranteeLetter], AlfastrahError>) -> Void
    )
}
