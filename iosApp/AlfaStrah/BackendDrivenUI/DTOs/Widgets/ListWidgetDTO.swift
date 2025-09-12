//
//  ListWidgetDTO.swift
//  AlfaStrah
//
//  Created by vit on 09.09.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

extension BDUI {
	class ListWidgetDTO: WidgetDTO {
		enum Key: String {
			case items = "items"
		}
		
		let items: [ListElementBackendComponent]?
		
		required init(body: [String: Any]) {
			self.items = Self.instantinate(Key.items, body)
			
			super.init(body: body)
		}
	}
	
	class ListElementBackendComponent: ComponentDTO {
		enum Key: String {
			case text = "text"
			case bullet = "bullet"
		}
		
		let themedIcon: ThemedValueComponentDTO?
		let themedText: ThemedTextComponentDTO?
		
		required init(body: [String: Any]) {
			self.themedText = Self.instantinate(Key.text, body)
			self.themedIcon = Self.instantinate(Key.bullet, body)
			
			super.init(body: body)
		}
	}
}
