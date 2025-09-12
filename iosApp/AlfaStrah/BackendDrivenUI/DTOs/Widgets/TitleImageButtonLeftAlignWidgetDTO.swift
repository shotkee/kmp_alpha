//
//  TitleImageButtonLeftAlignWidgetDTO.swift
//  AlfaStrah
//
//  Created by vit on 06.09.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

extension BDUI {
	class TitleImageButtonLeftAlignWidgetDTO: WidgetDTO {
		enum Key: String {
			case title = "title"
			case description = "description"
			case image = "image"
			case button = "button"
		}
		
		let title: ThemedTextComponentDTO?
		let description: ThemedTextComponentDTO?
		let image: ThemedValueComponentDTO?
		let button: WidgetDTO?
		
		required init(body: [String: Any]) {
			self.title = Self.instantinate(Key.title, body)
			self.description = Self.instantinate(Key.description, body)
			self.image = Self.instantinate(Key.image, body)
			self.button = Self.instantinate(Key.button, body)
			
			super.init(body: body)
		}
	}
}
