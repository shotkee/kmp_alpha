//
//  InsuranceContentComponentDTO.swift
//  AlfaStrah
//
//  Created by vit on 16.04.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

extension BDUI {
	class InsuranceContentComponentDTO: ComponentDTO {
		enum Key: String {
			case header = "header"
			case value = "value"
			case canCopyValue = "canCopyValue"
			case iconColor = "iconColor"
		}
		
		let header: ThemedTextComponentDTO?
		let value: ThemedTextComponentDTO?
		let isCopyable: Bool
		let iconColor: ThemedValueComponentDTO?
		
		required init(body: [String: Any]) {
			self.header = Self.instantinate(Key.header, body)
			self.value = Self.instantinate(Key.value, body)
			self.isCopyable = body[Key.canCopyValue.rawValue] as? Bool ?? false
			self.iconColor = Self.instantinate(Key.iconColor, body)
			
			super.init(body: body)
		}
	}
}
