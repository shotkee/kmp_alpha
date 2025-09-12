//
//  FilterEventItemWidgetDTO.swift
//  AlfaStrah
//
//  Created by vit on 18.07.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

extension BDUI {
	class FilterEventItemWidgetDTO: WidgetDTO {
		enum Key: String {
			case title = "title"
			case icon = "icon"
			case circle = "circle"
			case borderColor = "borderColor"
		}
		
		let themedTitle: ThemedTextComponentDTO?
		let themedIcon: ThemedValueComponentDTO?
		let themedMarkColor: ThemedValueComponentDTO?
		let themedBorderColor: ThemedValueComponentDTO?
		
		required init(body: [String: Any]) {
			self.themedTitle = Self.instantinate(Key.title, body)
			self.themedIcon = Self.instantinate(Key.icon, body)
			self.themedMarkColor = Self.instantinate(Key.circle, body)
			self.themedBorderColor = Self.instantinate(Key.borderColor, body)
			
			super.init(body: body)
		}
	}
}
