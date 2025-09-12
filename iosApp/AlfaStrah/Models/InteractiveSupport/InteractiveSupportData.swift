//
//  InteractiveSupportData.swift
//  AlfaStrah
//
//  Created by vit on 18.10.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

import Foundation

// sourcery: transformer
struct InteractiveSupportData {
    // sourcery: transformer.name = "insurance_id"
    let insuranceId: Int
    // sourcery: transformer.name = "insurance_title"
    let insuranceTitle: String
    // sourcery: transformer.name = "insurer"
    let insurer: String
    // sourcery: transformer.name = "insured"
    let insured: String
    // sourcery: transformer.name = "start_screen_data"
    let startScreenData: InteractiveSupportStartScreenData
}

// sourcery: transformer
struct InteractiveSupportStartScreenData {
    // sourcery: transformer.name = "title"
    let title: String
    // sourcery: transformer.name = "text"
    let text: String
    // sourcery: transformer.name = "button_text"
    let buttonTitle: String
}
