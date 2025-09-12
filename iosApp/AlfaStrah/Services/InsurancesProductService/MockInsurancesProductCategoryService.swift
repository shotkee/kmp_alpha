//
//  MockInsurancesProductCategoryService.swift
//  AlfaStrah
//
//  Created by Makson on 25.10.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

import Legacy

class MockInsurancesProductCategoryService: InsurancesProductCategoryService {
    private let rest: FullRestClient
    
    init(
        rest: FullRestClient
    ) {
        self.rest = rest
    }
   
    func getInsurancesProductList(completion: @escaping (Result<[InsuranceProductCategory], AlfastrahError>) -> Void) {
        completion(.success([]))
    }
    
    func getFilterInsurancesProductList(
        insuranceProductCategory: [InsuranceProductCategory],
        insuranceProductCategoryId: Int64
    ) -> [InsuranceProductCategory] {
        insuranceProductCategory
    }
    
    func performActionAfterAppIsReady(isUserAuthorized: Bool, completion: @escaping (Result<Void, ServiceUpdateError>) -> Void) {
        completion(.failure(.notImplemented))
    }
    
    func updateService(isUserAuthorized: Bool, completion: @escaping (Result<Void, ServiceUpdateError>) -> Void) {
        completion(.failure(.notImplemented))
    }
    
    func erase(logout: Bool) {}
}
