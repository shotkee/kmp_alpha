//
//  ThemedTextComponentDTO.swift
//  AlfaStrah
//
//  Created by vit on 16.04.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

extension BDUI {
	class ThemedTextComponentDTO: ComponentDTO {
		enum Key: String {
			case color = "color"
			case text = "text"
		}
		
		let themedColor: ThemedValueComponentDTO?
		let text: String?
		
		required init(body: [String: Any]) {
			self.themedColor = Self.instantinate(Key.color, body)
			self.text = body[Key.text.rawValue] as? String
			
			super.init(body: body)
		}
	}
}
