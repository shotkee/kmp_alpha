//
//  HeaderWidgetDTO.swift
//  AlfaStrah
//
//  Created by vit on 16.04.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

extension BDUI {
	class HeaderWidgetDTO: WidgetDTO {
		enum Key: String {
			case title = "title"
			case button = "button"
			case description = "description"
		}
		
		let title: ThemedSizedTextComponentDTO?
		let description: ThemedSizedTextComponentDTO?
		let button: InlineWidgetButtonComponentDTO?
		
		required init(body: [String: Any]) {
			self.title = Self.instantinate(Key.title, body)
			self.description = Self.instantinate(Key.description, body)
			self.button = Self.instantinate(Key.button, body)
			
			super.init(body: body)
		}
	}
}
