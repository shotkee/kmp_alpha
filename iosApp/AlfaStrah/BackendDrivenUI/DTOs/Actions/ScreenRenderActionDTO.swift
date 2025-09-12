//
//  ScreenRenderActionDTO.swift
//  AlfaStrah
//
//  Created by vit on 03.03.2025.
//  Copyright © 2025 Touch Instinct. All rights reserved.
//

extension BDUI {
	class ScreenRenderActionDTO: ActionDTO {
		enum Key: String {
			case screen = "screen"
		}
		
		let screen: (() -> ScreenComponentDTO?)?
		
		required init(body: [String: Any]) {
			self.screen = {
				if let body = body[Key.screen] as? [String: Any] {
					guard let screenType = body[ComponentDTO.Key.type] as? String
					else { return nil }

					return ScreenComponentDTO(body: body)
				} else if let screenType = body[ComponentDTO.Key.type] as? String {
					return ScreenComponentDTO(body: body)
				}
				
				return nil
			}
			
			super.init(body: body)
		}
		
		init(screen: (() -> ScreenComponentDTO?)?) {
			self.screen = screen
			
			super.init(.actionScreenRender)
		}
	}
}
