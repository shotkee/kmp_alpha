//
//  HorizontalScrollLayoutBDUI.swift
//  AlfaStrah
//
//  Created by vit on 16.04.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

extension BDUI {
	class HorizontalScrollLayoutDTO: LayoutDTO {
		enum Key: String {
			case cardWidth = "cardWidth"
			case content = "content"
			case cardWidthType = "cardWidthType"
		}
		
		let cardWidth: CGFloat?
		let cardWidthMode: CardWidthMode?
		let content: [WidgetDTO]?
		
		required init(body: [String: Any]) {
			self.cardWidth = body[Key.cardWidth] as? CGFloat
			self.cardWidthMode = CardWidthMode(rawValue: body[Key.cardWidthType] as? String ?? "")
			self.content = Self.instantinate(Key.content, body)
			
			super.init(body: body)
		}
	}
	
	enum CardWidthMode: String {
		case fixed = "Fixed"
		case dynamic = "Dynamic"
	}
}
