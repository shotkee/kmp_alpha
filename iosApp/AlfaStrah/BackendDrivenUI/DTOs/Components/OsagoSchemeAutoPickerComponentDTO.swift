//
//  OsagoSchemeAutoPickerComponentDTO.swift
//  AlfaStrah
//
//  Created by vit on 25.12.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

extension BDUI {
	class OsagoSchemeAutoPickerComponentDTO: ComponentDTO {
		enum Key: String {
			case title = "title"
			case subtitle = "subtitle"
			case arrowColor = "arrowColor"
			case listItems = "listItems"
			case button = "button"
		}
		
		let title: ThemedSizedTextComponentDTO?
		let subtitle: ThemedSizedTextComponentDTO?
		let arrowColor: ThemedValueComponentDTO?
		let lists: [SchemeItemsListComponentDTO]?
		let button: ButtonWidgetDTO?
		
		required init(body: [String: Any]) {
			self.title = Self.instantinate(Key.title, body)
			self.subtitle = Self.instantinate(Key.subtitle, body)
			self.arrowColor = Self.instantinate(Key.arrowColor, body)
			self.button = Self.instantinate(Key.button, body)
			
			self.lists = Self.instantinate(Key.listItems, body)
			
			super.init(body: body)
		}
	}
	
	class SchemeItemsListComponentDTO: ComponentDTO {
		enum Key: String {
			case title = "title"
			case items = "items"
		}
		
		let title: ThemedSizedTextComponentDTO?
		let items: [SchemeItemComponentDTO]?
		
		required init(body: [String: Any]) {
			self.title = Self.instantinate(Key.title, body)
			self.items = Self.instantinate(Key.items, body)
			
			super.init(body: body)
		}
	}
	
	class SchemeItemComponentDTO: ComponentDTO {
		enum Key: String {
			case id = "id"
			case title = "title"
			case isSelected = "isSelected"
		}
		
		let id: Int?
		let title: ThemedSizedTextComponentDTO?
		var isSelected: Bool
		
		required init(body: [String: Any]) {
			self.id = body[Key.id] as? Int
			self.title = Self.instantinate(Key.title, body)
			self.isSelected = body[Key.isSelected] as? Bool ?? false
			
			super.init(body: body)
		}
	}
}
