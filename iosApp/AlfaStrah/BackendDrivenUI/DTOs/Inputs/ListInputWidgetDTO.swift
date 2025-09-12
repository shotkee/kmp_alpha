//
//  ListInputWidgetDTO.swift
//  AlfaStrah
//
//  Created by vit on 11.12.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

extension BDUI {
	class ListInputWidgetDTO: TextInputWidgetDTO {
		enum Key: String {
			case values = "values"
			case button = "button"
			case dividerColor = "dividerColor"
			case arrowColor = "arrowColor"
			case multipleSelection = "multipleSelection"
			case title = "title"
			case subtitle = "subtitle"
		}
		
		let title: ThemedSizedTextComponentDTO?
		let subtitle: ThemedSizedTextComponentDTO?
		let items: [ListInputItemComponentDTO]?
		let button: ButtonWidgetDTO?
		let dividerColor: ThemedValueComponentDTO?
		let arrowColor: ThemedValueComponentDTO?
		let multipleSelection: Bool
		
		required init(body: [String: Any]) {
			self.title = Self.instantinate(Key.title, body)
			self.subtitle = Self.instantinate(Key.subtitle, body)
			self.items = Self.instantinate(Key.values, body)
			self.button = Self.instantinate(Key.button, body)
			self.dividerColor = Self.instantinate(Key.dividerColor, body)
			self.arrowColor = Self.instantinate(Key.arrowColor, body)
			self.multipleSelection = body[Key.multipleSelection] as? Bool ?? false
			
			super.init(body: body)
		}
	}
	
	class ListInputItemComponentDTO: ComponentDTO {
		enum Key: String {
			case id = "id"
			case input = "input"
			case value = "value"
		}
		
		let id: String?
		let text: ThemedSizedTextComponentDTO?
		let value: Any?
		
		required init(body: [String: Any]) {
			self.id = body[Key.id] as? String
			self.text = Self.instantinate(Key.input, body)
			self.value = body[Key.value]
			
			super.init(body: body)
		}
	}
}
