//
//  RowImageHeaderDescriptionButtonWidgetDTO.swift
//  AlfaStrah
//
//  Created by vit on 30.07.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

extension BDUI {
	class RowImageHeaderDescriptionButtonWidgetDTO: WidgetDTO {
		enum Key: String {
			case title = "title"
			case description = "description"
			case image = "image"
			case icon = "icon"
			case amount = "amount"
			case button = "button"
		}
		
		let themedAmount: ThemedTextComponentDTO?
		let widgetDto: WidgetDTO?
		let themedTitle: ThemedTextComponentDTO?
		let themedDescription: ThemedTextComponentDTO?
		let themedImage: ThemedValueComponentDTO?
		let themedIcon: ThemedValueComponentDTO?
		
		required init(body: [String: Any]) {
			self.themedAmount = Self.instantinate(Key.amount, body)
			self.themedTitle = Self.instantinate(Key.title, body)
			self.themedDescription = Self.instantinate(Key.description, body)
			self.themedImage = Self.instantinate(Key.image, body)
			self.themedIcon = Self.instantinate(Key.icon, body)
			self.widgetDto = Self.instantinate(Key.button, body)
			
			super.init(body: body)
		}
	}
}
