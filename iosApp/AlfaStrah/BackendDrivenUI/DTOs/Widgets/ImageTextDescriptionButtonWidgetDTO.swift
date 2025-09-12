//
//  ImageTextDescriptionButtonWidgetDTO.swift
//  AlfaStrah
//
//  Created by vit on 17.09.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

extension BDUI {
	class ImageTextDescriptionButtonWidgetDTO: WidgetDTO {
		enum Key: String {
			case button = "button"
			case title = "title"
			case image = "image"
			case description = "description"
		}
		
		let button: WidgetDTO?
		let themedTitle: ThemedTextComponentDTO?
		let themedDescription: ThemedTextComponentDTO?
		let themedImage: ThemedValueComponentDTO?
		
		required init(body: [String: Any]) {
			self.button = Self.instantinate(Key.button, body)
			self.themedTitle = Self.instantinate(Key.title, body)
			self.themedDescription = Self.instantinate(Key.description, body)
			self.themedImage = Self.instantinate(Key.image, body)
			
			super.init(body: body)
		}
	}
}
