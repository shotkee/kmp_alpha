//
//  ThemedValue.swift
//  AlfaStrah
//
//  Created by mac on 16.03.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

// sourcery: transformer
struct ThemedValue: Entity {
	// sourcery: transformer.name = "light"
	let light: String
	// sourcery: transformer.name = "dark"
	let dark: String
	
	func url(for style: UIUserInterfaceStyle) -> URL? {
		switch style {
			case .dark:
				return URL(string: dark)
			case .light, .unspecified:
				fallthrough
			@unknown default:
				return URL(string: light)
		}
	}

	func color(for style: UIUserInterfaceStyle) -> UIColor? {
		switch style {
			case .dark:
				return .from(hex: dark)
			case .light, .unspecified:
				fallthrough
			@unknown default:
				return .from(hex: light)
		}
	}
}
