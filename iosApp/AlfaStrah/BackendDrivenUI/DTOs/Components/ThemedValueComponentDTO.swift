//
//  ThemedValueComponentDTO.swift
//  AlfaStrah
//
//  Created by vit on 20.02.2025.
//  Copyright © 2025 Touch Instinct. All rights reserved.
//

extension BDUI {
	class ThemedValueComponentDTO: ComponentDTO {
		enum Key: String {
			case light = "light"
			case dark = "dark"
		}

		let light: String?
		let dark: String?
				
		required init(body: [String: Any]) {
			self.light = body[Key.light] as? String
			self.dark = body[Key.dark] as? String
			
			super.init(body: body)
		}
				
		func url(for style: UIUserInterfaceStyle) -> URL? {
			if let urlString = stringValue(for: style) {
				return  URL(string: urlString)
			}
			
			return nil
		}
				
		func color(for style: UIUserInterfaceStyle) -> UIColor? {
			if let colorHexString = stringValue(for: style) {
				return .from(hex: colorHexString)
			}
			
			return nil
		}
		
		private func stringValue(for style: UIUserInterfaceStyle) -> String? {
			switch style {
				case .dark:
					return dark
				case .light, .unspecified:
					fallthrough
				@unknown default:
					return light
			}
		}
	}
}
