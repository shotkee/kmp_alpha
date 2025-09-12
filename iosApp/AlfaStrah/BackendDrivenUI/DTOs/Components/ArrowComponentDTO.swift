//
//  ArrowComponentDTO.swift
//  AlfaStrah
//
//  Created by vit on 16.07.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

extension BDUI {
	class ArrowComponentDTO: ComponentDTO {
		enum Key: String {
			case color = "color"
		}
		
		let themedColor: ThemedValueComponentDTO?
		
		required init(body: [String: Any]) {
			self.themedColor = Self.instantinate(Key.color, body)
			
			super.init(body: body)
		}
	}
}
