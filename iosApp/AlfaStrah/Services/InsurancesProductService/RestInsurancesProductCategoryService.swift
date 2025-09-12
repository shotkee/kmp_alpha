//
//  RestInsurancesProductCategoryService.swift
//  AlfaStrah
//
//  Created by Makson on 25.10.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

import Legacy

class RestInsurancesProductCategoryService: InsurancesProductCategoryService {
    private let rest: FullRestClient
    
    init(
        rest: FullRestClient
    ) {
        self.rest = rest
    }
    
    func getInsurancesProductList(completion: @escaping (Result<[InsuranceProductCategory], AlfastrahError>) -> Void) {
       
        rest.read(
            path: "/api/insurances/products",
            id: nil,
            parameters: [:],
            headers: [:],
            responseTransformer: ResponseTransformer(
                key: "insurance_product_list",
                transformer: ArrayTransformer(transformer: InsuranceProductCategoryTransformer())
            ),
            completion: mapCompletion { [weak self] result in
                switch result {
                    case .success(let insuranceProductCategory):
                        completion(.success(insuranceProductCategory))
                    case .failure:
                        completion(.failure(.unknownError))
                }
            }
        )
    }
    
    func getFilterInsurancesProductList(
        insuranceProductCategory: [InsuranceProductCategory],
        insuranceProductCategoryId: Int64
    ) -> [InsuranceProductCategory] {
        
        guard let index = insuranceProductCategory.firstIndex(where: { $0.id == insuranceProductCategoryId }),
              let insuranceProduct = insuranceProductCategory[safe: index]
        else { return [] }
            
        return [insuranceProduct]
    }
    
    func performActionAfterAppIsReady(isUserAuthorized: Bool, completion: @escaping (Result<Void, ServiceUpdateError>) -> Void) {
        completion(.failure(.notImplemented))
    }
    
    func updateService(isUserAuthorized: Bool, completion: @escaping (Result<Void, ServiceUpdateError>) -> Void) {
        completion(.failure(.notImplemented))
    }
    
    func erase(logout: Bool) {}
}
