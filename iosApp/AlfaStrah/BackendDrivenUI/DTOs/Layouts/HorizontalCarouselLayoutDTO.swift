//
//  HorizontalCarouselLayoutBDUI.swift
//  AlfaStrah
//
//  Created by vit on 12.02.2025.
//  Copyright © 2025 Touch Instinct. All rights reserved.
//

extension BDUI {
	class HorizontalCarouselLayoutDTO: LayoutDTO {
		enum Key: String {
			case colorActiveItem = "colorActiveItem"
			case colorInactiveItem = "colorInactiveItem"
			case content = "content"
		}
		
		let activeColor: ThemedValueComponentDTO?
		let inactiveColor: ThemedValueComponentDTO?
		let content: [WidgetDTO]?
		
		required init(body: [String: Any]) {
			self.activeColor = Self.instantinate(Key.colorActiveItem, body)
			self.inactiveColor = Self.instantinate(Key.colorInactiveItem, body)
			self.content = Self.instantinate(Key.content, body)
			
			super.init(body: body)
		}
	}
}
