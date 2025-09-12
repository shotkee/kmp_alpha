//
//  BankDadataInputWidgetDTO.swift
//  AlfaStrah
//
//  Created by vit on 17.12.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

extension BDUI {
	class BankDadataInputWidgetDTO: TextInputWidgetDTO {
		enum Key: String {
			case title = "title"
			case text = "text"
			case button = "button"
		}
		
		let title: ThemedSizedTextComponentDTO?
		let	subtitle: ThemedSizedTextComponentDTO?
		let button: ButtonWidgetDTO?
		
		required init(body: [String: Any]) {
			self.title = Self.instantinate(Key.title, body)
			self.subtitle = Self.instantinate(Key.text, body)
			self.button = Self.instantinate(Key.button, body)
			
			super.init(body: body)
		}
	}
}
