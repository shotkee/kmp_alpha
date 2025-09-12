//
//  InsuranceProductCategory.swift
//  AlfaStrah
//
//  Created by Makson on 25.10.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

// sourcery: transformer
struct InsuranceProductCategory {
    // sourcery: transformer.name = "category_id"
    let id: Int64
    // sourcery: transformer.name = "title"
    let title: String
    // sourcery: transformer.name = "product_list"
    let productList: [InsuranceProduct]
    // sourcery: transformer.name = "show_in_filters"
    let showInFilters: Bool
}
