//
//  NavigateBackToActionDTO.swift
//  AlfaStrah
//
//  Created by vit on 03.03.2025.
//  Copyright © 2025 Touch Instinct. All rights reserved.
//

extension BDUI {
	class NavigateBackToActionDTO: ActionDTO {
		enum Key: String {
			case screenId = "screenId"
		}
		
		let screenId: String?
		
		required init(body: [String: Any]) {
			self.screenId = body[Key.screenId] as? String
			
			super.init(body: body)
		}
	}
}
