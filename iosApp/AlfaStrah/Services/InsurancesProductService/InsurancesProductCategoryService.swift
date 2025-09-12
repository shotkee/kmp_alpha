//
//  InsurancesProductCategoryService.swift
//  AlfaStrah
//
//  Created by Makson on 25.10.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

protocol InsurancesProductCategoryService: Updatable {
    func getInsurancesProductList(
        completion: @escaping (Result<[InsuranceProductCategory], AlfastrahError>) -> Void
    )
    func getFilterInsurancesProductList(
        insuranceProductCategory: [InsuranceProductCategory],
        insuranceProductCategoryId: Int64
    ) -> [InsuranceProductCategory]
}
