//
//  ThemedButton.swift
//  AlfaStrah
//
//  Created by vit on 18.06.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

// sourcery: transformer
struct ThemedButton: Entity {
	// sourcery: transformer.name = "button_text_color_themed"
	let themedTextColor: ThemedValue?
	// sourcery: transformer.name = "button_color_themed"
	let themedBackgroundColor: ThemedValue?
	// sourcery: transformer.name = "border"
	let themedBorderColor: ThemedValue?
	// sourcery: transformer.name = "action"
	let action: BackendAction?
}
