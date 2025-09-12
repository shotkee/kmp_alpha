//
//  OneColumnLayoutDTO.swift
//  AlfaStrah
//
//  Created by vit on 16.04.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

extension BDUI {
	class OneColumnLayoutDTO: LayoutDTO {
		enum Key: String {
			case content = "content"
		}
		
		let content: [WidgetDTO]?
		
		required init(body: [String: Any]) {
			self.content = Self.instantinate(Key.content, body)
			
			super.init(body: body)
		}
	}
}
