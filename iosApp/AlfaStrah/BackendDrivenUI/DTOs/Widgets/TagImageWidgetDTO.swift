//
//  TagImageWidgetDTO.swift
//  AlfaStrah
//
//  Created by vit on 09.09.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

extension BDUI {
	class TagImageWidgetDTO: WidgetDTO {
		enum Key: String {
			case title = "title"
			case description = "description"
			case image = "image"
			case tags = "tags"
		}
		
		let themedTitle: ThemedTextComponentDTO?
		let themedDescription: ThemedTextComponentDTO?
		let themedImage: ThemedValueComponentDTO?
		let tags: [TagWithIconWidgetDTO]?
		
		required init(body: [String: Any]) {
			self.themedTitle = Self.instantinate(Key.title, body)
			self.themedDescription = Self.instantinate(Key.description, body)
			self.themedImage = Self.instantinate(Key.image, body)
			
			self.tags = Self.instantinate(Key.tags, body)
			
			super.init(body: body)
		}
	}
}
