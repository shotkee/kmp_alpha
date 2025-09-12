//
//  PhoneBackendComponent.swift
//  AlfaStrah
//
//  Created by vit on 17.04.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

extension BDUI {
	class PhoneComponentDTO: ComponentDTO {
		enum Key: String {
			case humanReadable = "humanReadable"
			case canCopyValue = "canCopyValue"
			case canMakeCall = "canMakeCall"
			case plain = "plain"
		}
		
		let humanReadable: String?
		let canCopyValue: Bool?
		let canMakeCall: Bool?
		let plain: String?
		
		required init(body: [String: Any]) {
			self.humanReadable = body[Key.humanReadable] as? String
			self.canCopyValue = body[Key.canCopyValue] as? Bool
			self.canMakeCall = body[Key.canMakeCall] as? Bool
			self.plain = body[Key.plain] as? String
			
			super.init(body: body)
		}
	}
}
