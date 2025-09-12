//
//  ClinicServiceHoursOption.swift
//  AlfaStrah
//
//  Created by Vitaly Trofimov on 16.11.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

import Foundation

// sourcery: transformer
struct ClinicServiceHoursOption: Hashable
{
    // sourcery: transformer.name = "code"
    let code: String
    
    // sourcery: transformer.name = "title"
    let title: String
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(code)
    }
}
