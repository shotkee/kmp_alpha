//
//  RestInsuranceLifeService.swift
//  AlfaStrah
//
//  Created by mac on 13.02.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

import Legacy

class RestInsuranceLifeService: InsuranceLifeService {
	private let rest: FullRestClient
	
	init(rest: FullRestClient) {
		self.rest = rest
	}
	
	func questionsAndAnswersUrl(insuranceId: String, completion: @escaping (Result<URL, AlfastrahError>) -> Void) {
		rest.read(
			path: "/api/insurances/life/faq",
			id: nil,
			parameters: [ "insurance_id": insuranceId ],
			headers: [:],
			responseTransformer: ResponseTransformer(key: "url", transformer: UrlTransformer<Any>()),
			completion: mapCompletion(completion)
		)
	}
	
	func accidentUrl(insuranceId: String, completion: @escaping (Result<URL, AlfastrahError>) -> Void) {
		rest.read(
			path: "/api/insurances/life/accident",
			id: nil,
			parameters: [ "insurance_id": insuranceId ],
			headers: [:],
			responseTransformer: ResponseTransformer(key: "url", transformer: UrlTransformer<Any>()),
			completion: mapCompletion(completion)
		)
	}
}
