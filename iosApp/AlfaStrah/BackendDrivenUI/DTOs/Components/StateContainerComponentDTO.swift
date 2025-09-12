//
//  StateContainerComponentDTO.swift
//  AlfaStrah
//
//  Created by vit on 15.11.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

extension BDUI {
	class StateContainerComponentDTO: ComponentDTO {
		enum Key: String {
			case activeStateWidget = "activeState"
			case nonActiveStateWidget = "notActiveState"
			case isActive = "isActive"
		}
		
		let activeStateWidget: WidgetDTO?
		let nonActiveStateWidget: WidgetDTO?
		var isActive: Bool
		
		required init(body: [String: Any]) {
			self.activeStateWidget = Self.instantinate(Key.activeStateWidget, body)
			self.nonActiveStateWidget = Self.instantinate(Key.nonActiveStateWidget, body)
			self.isActive = body[Key.isActive] as? Bool ?? false
			
			super.init(body: body)
		}
	}
}
