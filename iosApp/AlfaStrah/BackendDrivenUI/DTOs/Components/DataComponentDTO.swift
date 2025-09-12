//
//  DataComponentDTO.swift
//  AlfaStrah
//
//  Created by vit on 16.04.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

extension BDUI {
	class DataComponentDTO: ComponentDTO {
		enum Key: String {
			case screen = "screen"
		}
		
		let screen: ScreenComponentDTO?
		
		required init(body: [String: Any]) {
			self.screen = Self.instantinate(Key.screen, body)
			
			super.init(body: body)
		}
	}
}
