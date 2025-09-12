//
//  SquaredButtonWidgetDTO.swift
//  AlfaStrah
//
//  Created by vit on 22.07.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

extension BDUI {
	class SquaredButtonWidgetDTO: WidgetDTO {
		enum Key: String {
			case title = "title"
			case borderColor = "borderColor"
			case icon = "icon"
			case arrow = "arrow"
		}
		
		let themedTitle: ThemedTextComponentDTO?
		let themedBorderColor: ThemedValueComponentDTO?
		let themedIcon: ThemedValueComponentDTO?
		let arrow: ArrowComponentDTO?
		
		required init(body: [String: Any]) {
			self.themedTitle = Self.instantinate(Key.title, body)
			self.themedBorderColor = Self.instantinate(Key.borderColor, body)
			self.themedIcon = Self.instantinate(Key.icon, body)
			self.arrow = Self.instantinate(Key.arrow, body)
			
			super.init(body: body)
		}
	}
}
