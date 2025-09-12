//
//  RowWithIconBlockWidgetDTO.swift
//  AlfaStrah
//
//  Created by vit on 16.04.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

extension BDUI {
	class RowWithIconBlockWidgetDTO: WidgetDTO {
		enum Key: String {
			case title = "title"
			case color = "color"
			case icon = "icon"
			case arrow = "arrow"
		}
		
		let title: ThemedTextComponentDTO?
		let themedIcon: ThemedValueComponentDTO?
		let accessoryImageThemedColor: ThemedValueComponentDTO?
		
		required init(body: [String: Any]) {
			self.title = Self.instantinate(Key.title, body)
			self.themedIcon = Self.instantinate(Key.icon, body)
			self.accessoryImageThemedColor = Self.instantinate(Key.color, body[Key.arrow] as? [String: Any])
			
			super.init(body: body)
		}
	}
}
