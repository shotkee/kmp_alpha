//
//  ImageWidgetDTO.swift
//  AlfaStrah
//
//  Created by vit on 28.08.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

extension BDUI {
	class ImageWidgetDTO: WidgetDTO {
		enum Key: String {
			case image = "image"
			case align = "align"
		}
		
		enum Align: String {
			case left = "Left"
			case center = "Center"
			case right = "Right"
			case fill = "Fill"
		}
		
		let image: ThemedValueComponentDTO?
		let align: Align?
		
		required init(body: [String: Any]) {
			self.image = Self.instantinate(Key.image, body)
			self.align = Align(rawValue: body[Key.align] as? String ?? Align.fill.rawValue)
			
			super.init(body: body)
		}
	}
}
