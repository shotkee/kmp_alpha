//
//  ScreenRequestActionDTO.swift
//  AlfaStrah
//
//  Created by vit on 03.03.2025.
//  Copyright © 2025 Touch Instinct. All rights reserved.
//

extension BDUI {
	class ScreenRequestActionDTO: ActionDTO {
		let request: RequestComponentDTO?
		
		required init(body: [String: Any]) {
			self.request = Self.instantinate(body)
			
			super.init(body: body)
		}
	}
}
