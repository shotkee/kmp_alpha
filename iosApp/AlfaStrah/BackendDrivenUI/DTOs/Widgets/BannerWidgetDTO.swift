//
//  BannerWidgetDTO.swift
//  AlfaStrah
//
//  Created by vit on 24.07.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

extension BDUI {
	class BannerWidgetDTO: WidgetDTO {
		enum Key: String {
			case title = "title"
			case description = "description"
			case image = "image"
		}
		
		let themedTitle: ThemedTextComponentDTO?
		let themedDescription: ThemedTextComponentDTO?
		let themedImage: ThemedValueComponentDTO?
		
		required init(body: [String: Any]) {
			self.themedTitle = Self.instantinate(Key.title, body)
			self.themedDescription = Self.instantinate(Key.description, body)
			self.themedImage = Self.instantinate(Key.image, body)
			
			super.init(body: body)
		}
	}
}
