//
//  Draft.swift
//  AlfaStrah
//
//  Created by mac on 27.11.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

import Foundation

// sourcery: transformer
struct DraftsCalculationsData {
    // sourcery: transformer.name = "draft_id"
    let id: Int
    
    // sourcery: transformer.name = "calculation_title"
    let title: String
    
    // sourcery: transformer.name = "calculation_number"
    let calculationNumber: String
    
    // sourcery: transformer.name = "calculation_date"
    // sourcery: transformer = "DateTransformer<Any>()"
    let date: Date
    
    // sourcery: transformer.name = "days_until_delete"
    let daysUntilDelete: String?
    
    // sourcery: transformer.name = "parameter_list"
    let parameters: [FieldList]
    
    // sourcery: transformer.name = "price"
    let price: String?
    
    // sourcery: transformer.name = "redirect_url", transformer = "UrlTransformer<Any>()"
    let url: URL?
}
