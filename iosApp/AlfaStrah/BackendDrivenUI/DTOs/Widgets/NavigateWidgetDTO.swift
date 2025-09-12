//
//  NavigateWidgetBDUI.swift
//  AlfaStrah
//
//  Created by vit on 05.09.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

extension BDUI {
	class NavigateWidgetDTO: WidgetDTO {
		enum Key: String {
			case items = "items"
			case paddingHorizontal = "paddingHorizontal"
		}
		
		let items: [StateContainerComponentDTO]?
		let paddingHorizontal: CGFloat?
		
		required init(body: [String: Any]) {
			self.items = Self.instantinate(Key.items, body)
			self.paddingHorizontal = body[Key.paddingHorizontal] as? CGFloat
			
			super.init(body: body)
		}
	}
}
