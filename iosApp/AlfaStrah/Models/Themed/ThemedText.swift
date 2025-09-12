//
//  ThemedText.swift
//  AlfaStrah
//
//  Created by vit on 18.06.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

// sourcery: transformer
struct ThemedText: Entity {
	// sourcery: transformer.name = "text"
	let text: String
	// sourcery: transformer.name = "color"
	let themedColor: ThemedValue?
}
