//
//  ButtonWidgetDTO.swift
//  AlfaStrah
//
//  Created by vit on 16.04.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

extension BDUI {
	class ButtonWidgetDTO: WidgetDTO {
		enum Key: String {
			case title = "title"
			case borderColor = "borderColor"
			case leftIcon = "leftIcon"
		}
		
		let themedTitle: ThemedTextComponentDTO?
		let themedBorderColor: ThemedValueComponentDTO?
		let leftThemedIcon: ThemedValueComponentDTO?
		
		required init(body: [String: Any]) {
			self.themedBorderColor = Self.instantinate(Key.borderColor, body)
			self.themedTitle = Self.instantinate(Key.title, body)
			self.leftThemedIcon = Self.instantinate(Key.leftIcon, body)
			
			super.init(body: body)
		}
	}
}
