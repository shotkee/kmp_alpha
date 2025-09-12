//
//  TwoColumnListWidgetDTO.swift
//  AlfaStrah
//
//  Created by vit on 29.10.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

extension BDUI {
	class TwoColumnListWidgetDTO: WidgetDTO {
		enum Key: String {
			case items = "items"
		}
		
		let items: [TwoColumnListWidgetItemComponentDTO]?
		
		required init(body: [String: Any]) {
			self.items = Self.instantinate(Key.items, body)
			
			super.init(body: body)
		}
	}
	
	class TwoColumnListWidgetItemComponentDTO: ComponentDTO {
		enum Key: String {
			case title = "title"
			case rightText = "rightText"
			case description = "description"
		}
		
		let title: ThemedSizedTextComponentDTO?
		let rightText: ThemedSizedTextComponentDTO?
		let description: ThemedSizedTextComponentDTO?
		
		required init(body: [String: Any]) {
			self.title = Self.instantinate(Key.title, body)
			self.rightText = Self.instantinate(Key.rightText, body)
			self.description = Self.instantinate(Key.description, body)
			
			super.init(body: body)
		}
	}
}
