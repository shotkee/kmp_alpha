//
//  InsuranceLiveService.swift
//  AlfaStrah
//
//  Created by mac on 13.02.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

protocol InsuranceLifeService {
	func questionsAndAnswersUrl(insuranceId: String, completion: @escaping (Result<URL, AlfastrahError>) -> Void)
	func accidentUrl(insuranceId: String, completion: @escaping (Result<URL, AlfastrahError>) -> Void)
}
