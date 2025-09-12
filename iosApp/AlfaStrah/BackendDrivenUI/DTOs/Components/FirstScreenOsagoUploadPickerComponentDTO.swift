//
//  FirstScreenOsagoUploadPickerComponentDTO.swift
//  AlfaStrah
//
//  Created by vit on 21.02.2025.
//  Copyright © 2025 Touch Instinct. All rights reserved.
//

extension BDUI {
	class FirstScreenOsagoUploadPickerComponentDTO: ComponentDTO {
		enum Key: String {
			case countText = "countText"
			case title = "title"
			case subtitle = "subtitle"
			case image = "image"
			case button = "button"
		}
		
		let countText: ThemedSizedTextComponentDTO?
		let title: ThemedSizedTextComponentDTO?
		let subtitle: ThemedSizedTextComponentDTO?
		let image: ThemedValueComponentDTO?
		let button: ButtonWidgetDTO?
		
		required init(body: [String: Any]) {
			self.countText = Self.instantinate(Key.countText, body)
			self.title = Self.instantinate(Key.title, body)
			self.subtitle = Self.instantinate(Key.subtitle, body)
			self.image = Self.instantinate(Key.image, body)
			self.button = Self.instantinate(Key.button, body)
			
			super.init(body: body)
		}
	}
}
