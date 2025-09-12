//
//  WebViewActionDTO.swift
//  AlfaStrah
//
//  Created by vit on 03.03.2025.
//  Copyright © 2025 Touch Instinct. All rights reserved.
//

extension BDUI {
	class WebViewActionDTO: ActionDTO {
		let event: WebViewEventComponentDTO?
		
		required init(body: [String: Any]) {
			self.event = Self.instantinate(body)
			
			super.init(body: body)
		}
	}
}
