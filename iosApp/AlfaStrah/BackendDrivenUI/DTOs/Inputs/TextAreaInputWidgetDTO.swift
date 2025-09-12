//
//  TextAreaInputWidgetDTO.swift
//  AlfaStrah
//
//  Created by vit on 20.11.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

extension BDUI {
	class TextAreaInputWidgetDTO: TextInputWidgetDTO {
		enum Key: String {
			case minHeight = "minHeight"
		}
		
		let minHeight: CGFloat?
		
		required init(body: [String: Any]) {
			self.minHeight = body[Key.minHeight] as? CGFloat
			
			super.init(body: body)
		}
	}
}
