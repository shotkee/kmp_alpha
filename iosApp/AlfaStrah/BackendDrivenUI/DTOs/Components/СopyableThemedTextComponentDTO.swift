//
//  СopyableThemedTextComponentDTO.swift
//  AlfaStrah
//
//  Created by vit on 22.07.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

extension BDUI {
	class СopyableThemedTextComponentDTO: ComponentDTO {
		enum Key: String {
			case text = "text"
			case canCopyValue = "canCopyValue"
			case iconColor = "iconColor"
		}
		
		let themedText: ThemedSizedTextComponentDTO?
		let isCopyable: Bool
		let iconColor: ThemedValueComponentDTO?
		
		required init(body: [String: Any]) {
			self.themedText = Self.instantinate(Key.text, body)
			self.isCopyable = body[Key.canCopyValue] as? Bool ?? false
			self.iconColor = Self.instantinate(Key.iconColor, body)
			
			super.init(body: body)
		}
	}
}
