//
//  ScreenNavigationButtonComponentDTO.swift
//  AlfaStrah
//
//  Created by vit on 16.04.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

extension BDUI {
	class ScreenNavigationButtonComponentDTO: ComponentDTO {
		enum Key: String {
			case color = "color"
			case screenId = "screenId"
		}
		
		let color: ThemedValueComponentDTO?
		let screenId: String?
		
		required init(body: [String: Any]) {
			self.color = Self.instantinate(Key.color, body)
			self.screenId = body[Key.screenId.rawValue] as? String
			
			super.init(body: body)
		}
	}
}
