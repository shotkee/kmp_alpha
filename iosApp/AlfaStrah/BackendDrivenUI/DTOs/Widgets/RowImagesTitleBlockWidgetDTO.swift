//
//  RowImagesTitleBlockWidgetDTO.swift
//  AlfaStrah
//
//  Created by vit on 28.08.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

extension BDUI {
	class RowImagesTitleBlockWidgetDTO: WidgetDTO {
		enum Key: String {
			case title = "title"
			case items = "items"
		}
		
		let title: ThemedTextComponentDTO?
		let items: [RowImagesTitleBlockItemComponentDTO]?
		
		required init(body: [String: Any]) {
			self.title = Self.instantinate(Key.title, body)
			self.items = Self.instantinate(Key.items, body)
			
			super.init(body: body)
		}
	}
	
	class RowImagesTitleBlockItemComponentDTO: ComponentDTO {
		enum Key: String {
			case image = "image"
			case text = "text"
		}
		
		let title: ThemedTextComponentDTO?
		let image: ThemedValueComponentDTO?
		
		required init(body: [String: Any]) {
			self.title = Self.instantinate(Key.text, body)
			self.image = Self.instantinate(Key.image, body)
			
			super.init(body: body)
		}
	}
}
