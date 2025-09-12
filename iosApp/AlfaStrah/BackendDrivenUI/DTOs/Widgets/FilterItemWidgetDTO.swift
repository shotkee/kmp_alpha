//
//  FilterItemWidgetDTO.swift
//  AlfaStrah
//
//  Created by vit on 17.07.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

extension BDUI {
	class FilterItemWidgetDTO: WidgetDTO {
		enum Key: String {
			case title = "title"
			case active = "active"
		}
		
		let themedTitle: ThemedTextComponentDTO?
		let underlineThemedColor: ThemedValueComponentDTO?
		
		required init(body: [String: Any]) {
			self.themedTitle = Self.instantinate(Key.title, body)
			self.underlineThemedColor = Self.instantinate(Key.active, body)
			
			super.init(body: body)
		}
	}
}
