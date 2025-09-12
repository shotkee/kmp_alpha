//
//  LinkedTextWidgetDTO.swift
//  AlfaStrah
//
//  Created by vit on 09.09.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

extension BDUI {
	class LinkedTextWidgetDTO: WidgetDTO {
		enum Key: String {
			case text = "text"
		}
		
		let text: [InlineWidgetButtonComponentDTO]?
		
		required init(body: [String: Any]) {
			self.text = Self.instantinate(Key.text, body)
			
			super.init(body: body)
		}
	}
}
