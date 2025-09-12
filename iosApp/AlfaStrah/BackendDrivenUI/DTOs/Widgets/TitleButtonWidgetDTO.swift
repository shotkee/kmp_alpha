//
//  TitleButtonWidgetDTO.swift
//  AlfaStrah
//
//  Created by vit on 25.10.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

extension BDUI {
	class TitleButtonWidgetDTO: WidgetDTO {
		enum Key: String {
			case title = "title"
			case button = "button"
		}
		
		let title: ThemedSizedTextComponentDTO?
		let button: WidgetDTO?
		
		required init(body: [String: Any]) {
			self.title = Self.instantinate(Key.title, body)
			self.button = Self.instantinate(Key.button, body)
			
			super.init(body: body)
		}
	}
}
