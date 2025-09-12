//
//  VerticalCustomRadioButtonWidgetDTO.swift
//  AlfaStrah
//
//  Created by vit on 15.11.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

extension BDUI {
	class VerticalCustomRadioButtonWidgetDTO: WidgetDTO {
		enum Key: String {
			case paddingVertical = "paddingVertical"
			case items = "items"
		}
		
		let items: [StateContainerComponentDTO]?
		let paddingVertical: CGFloat?
		
		required init(body: [String: Any]) {
			self.paddingVertical = body[Key.paddingVertical] as? CGFloat
			self.items = Self.instantinate(Key.items, body)
			
			super.init(body: body)
		}
	}
}
