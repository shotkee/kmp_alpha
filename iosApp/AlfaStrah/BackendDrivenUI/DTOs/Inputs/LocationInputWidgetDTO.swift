//
//  LocationInputWidgetDTO.swift
//  AlfaStrah
//
//  Created by vit on 27.11.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

extension BDUI {
	class LocationInputWidgetDTO: TextInputWidgetDTO {
		enum Key: String {
			case title = "title"
			case modalTitle = "modalTitle"
			case subtitle = "subtitle"
			case button = "button"
			case allowMapSelect = "allowMapSelect"
		}
		
		let title: ThemedSizedTextComponentDTO?
		let modalTitle: ThemedSizedTextComponentDTO?
		let subtitle: ThemedSizedTextComponentDTO?
		let button: ButtonWidgetDTO?
		let allowMapSelect: Bool
		
		required init(body: [String: Any]) {
			self.title = Self.instantinate(Key.title, body)
			self.modalTitle = Self.instantinate(Key.modalTitle, body)
			self.subtitle = Self.instantinate(Key.subtitle, body)
			self.button = Self.instantinate(Key.button, body)
			
			self.allowMapSelect = body[Key.allowMapSelect] as? Bool ?? false
			
			super.init(body: body)
		}
	}
}
