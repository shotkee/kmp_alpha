//
//  ActionRequestActionDTO.swift
//  AlfaStrah
//
//  Created by vit on 03.03.2025.
//  Copyright © 2025 Touch Instinct. All rights reserved.
//

extension BDUI {
	class ActionRequestActionDTO: ActionDTO {
		enum Key: String {
			case action = "action"
		}
		
		let request: RequestComponentDTO?
		
		required init(body: [String: Any]) {
			self.request = Self.instantinate(Key.action, body) ?? Self.instantinate(body)
			
			super.init(body: body)
		}
	}
}
