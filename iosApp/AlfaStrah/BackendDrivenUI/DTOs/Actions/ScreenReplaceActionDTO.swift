//
//  ScreenReplaceActionDTO.swift
//  AlfaStrah
//
//  Created by vit on 03.03.2025.
//  Copyright © 2025 Touch Instinct. All rights reserved.
//

extension BDUI {
	class ScreenReplaceActionDTO: ActionDTO {
		enum Key: String {
			case screenId = "screenId"
			case screen = "screen"
		}
		
		let screenId: String?
		let screen: (() -> ScreenComponentDTO?)?
		
		required init(body: [String: Any]) {
			if let body = body[Key.screen] as? [String: Any] {
				self.screenId = body[Key.screenId] as? String
				self.screen = {
					return ScreenComponentDTO(body: body)
				}
			} else {
				self.screenId = body[Key.screenId] as? String
				self.screen = {
					return ScreenComponentDTO(body: body)
				}
			}
			
			super.init(body: body)
		}
	}
}
