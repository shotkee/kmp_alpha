//
//  AlertActionDTO.swift
//  AlfaStrah
//
//  Created by vit on 03.03.2025.
//  Copyright © 2025 Touch Instinct. All rights reserved.
//

extension BDUI {
	class AlertActionDTO: ActionDTO {
		let alert: AlertComponentDTO?
		
		required init(body: [String: Any]) {
			self.alert = Self.instantinate(body)
			
			super.init(body: body)
		}
	}
}
