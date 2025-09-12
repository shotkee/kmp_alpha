//
//  BackendButton.swift
//  AlfaStrah
//
//  Created by vit on 02.11.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

import Foundation

// sourcery: transformer
struct BackendButton {
    // sourcery: transformer.name = "button_text_color"
    let textHexColor: String
	
	// sourcery: transformer.name = "button_text_color_themed"
	let textHexColorThemed: ThemedValue?
    
    // sourcery: transformer.name = "button_color"
    let backgroundHexColor: String
	
	// sourcery: transformer.name = "button_color_themed"
	let backgroundHexColorThemed: ThemedValue?
    
    // sourcery: transformer.name = "action"
    let action: BackendAction
}
