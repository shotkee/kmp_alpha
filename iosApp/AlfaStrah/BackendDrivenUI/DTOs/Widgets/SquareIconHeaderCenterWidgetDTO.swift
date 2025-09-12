//
//  SquareIconHeaderCenterWidgetDTO.swift
//  AlfaStrah
//
//  Created by vit on 25.07.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

extension BDUI {
	class SquareIconHeaderCenterWidgetDTO: WidgetDTO {
		enum Key: String {
			case title = "title"
			case icon = "icon"
		}
		
		let themedTitle: ThemedTextComponentDTO?
		let themedIcon: ThemedValueComponentDTO?
		
		required init(body: [String: Any]) {
			self.themedTitle = Self.instantinate(Key.title, body)
			self.themedIcon = Self.instantinate(Key.icon, body)
			
			super.init(body: body)
		}
	}
}
