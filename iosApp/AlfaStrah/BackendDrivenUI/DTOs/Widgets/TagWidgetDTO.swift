//
//  TagWidgetDTO.swift
//  AlfaStrah
//
//  Created by vit on 21.02.2025.
//  Copyright © 2025 Touch Instinct. All rights reserved.
//

extension BDUI {
	class TagWidgetDTO: WidgetDTO {
		enum Key: String {
			case title = "title"
			case icon = "icon"
		}
		
		let title: ThemedSizedTextComponentDTO?
		let icon: ThemedValueComponentDTO?
		
		required init(body: [String: Any]) {
			self.title = Self.instantinate(Key.title, body)
			self.icon = Self.instantinate(Key.icon, body)
			
			super.init(body: body)
		}
	}
}
