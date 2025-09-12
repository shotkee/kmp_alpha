//
//  InformationWidgetDTO.swift
//  AlfaStrah
//
//  Created by vit on 23.04.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

extension BDUI {
	class InformationWidgetDTO: WidgetDTO {
		enum Key: String {
			case title = "title"
			case icon = "icon"
		}
		
		let title: ThemedTextComponentDTO?
		let themedIcon: ThemedValueComponentDTO?
		
		required init(body: [String: Any]) {
			self.title = Self.instantinate(Key.title, body)
			self.themedIcon = Self.instantinate(Key.icon, body)
			
			super.init(body: body)
		}
	}
}
