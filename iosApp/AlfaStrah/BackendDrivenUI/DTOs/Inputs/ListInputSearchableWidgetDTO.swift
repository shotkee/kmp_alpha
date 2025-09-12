//
//  ListInputSearchableWidgetDTO.swift
//  AlfaStrah
//
//  Created by vit on 12.12.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

extension BDUI {
	class ListInputSearchableWidgetDTO: TextInputWidgetDTO {
		enum Key: String {
			case values = "values"
			case button = "button"
			case title = "title"
			case subtitle = "subtitle"
		}
		
		let title: ThemedSizedTextComponentDTO?
		let subtitle: ThemedSizedTextComponentDTO?
		let items: [ListInputSearchableItemBackendComponent]?
		let button: ButtonWidgetDTO?
		
		required init(body: [String: Any]) {
			self.title = Self.instantinate(Key.title, body)
			self.subtitle = Self.instantinate(Key.subtitle, body)
			self.items = Self.instantinate(Key.values, body)
			self.button = Self.instantinate(Key.button, body)
			
			super.init(body: body)
		}
	}
	
	class ListInputSearchableItemBackendComponent: ComponentDTO {
		enum Key: String {
			case input = "input"
			case value = "value"
		}
		
		let text: ThemedSizedTextComponentDTO?
		let value: [String: Any?]?
		
		required init(body: [String: Any]) {
			self.text = Self.instantinate(Key.input, body)
			self.value = body[Key.value] as? [String: Any?]
			
			super.init(body: body)
		}
	}
}
