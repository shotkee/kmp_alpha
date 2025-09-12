//
//  PhoneActionDTO.swift
//  AlfaStrah
//
//  Created by vit on 03.03.2025.
//  Copyright © 2025 Touch Instinct. All rights reserved.
//

extension BDUI {
	class PhoneActionDTO: ActionDTO {
		enum Key: String {
			case phone = "phone"
		}
		
		let phone: PhoneComponentDTO?
		
		required init(body: [String: Any]) {
			self.phone = Self.instantinate(Key.phone, body)
			
			super.init(body: body)
		}
	}
}
