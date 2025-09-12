//
//  ImageTextLinkWidgetDTO.swift
//  AlfaStrah
//
//  Created by vit on 25.07.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

extension BDUI {
	class ImageTextLinkWidgetDTO: WidgetDTO {
		enum Key: String {
			case title = "title"
			case description = "description"
			case image = "image"
			case button = "button"
		}
		
		let themedTitle: ThemedTextComponentDTO?
		let themedDescription: ThemedTextComponentDTO?
		let themedImage: ThemedValueComponentDTO?
		let button: EventButtonComponentDTO?
		
		required init(body: [String: Any]) {
			self.themedTitle = Self.instantinate(Key.title, body)
			self.themedDescription = Self.instantinate(Key.description, body)
			self.themedImage = Self.instantinate(Key.image, body)
			self.button = Self.instantinate(Key.button, body)
			
			super.init(body: body)
		}
	}
}
