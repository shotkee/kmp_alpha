//
//  HeaderIconWidgetDTO.swift
//  AlfaStrah
//
//  Created by vit on 28.10.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

extension BDUI {
	class HeaderIconWidgetDTO: WidgetDTO {
		enum Key: String {
			case leftText = "leftText"
			case icon = "icon"
			case rightText = "rightText"
		}
		
		let leftText: ThemedSizedTextComponentDTO?
		let icon: ThemedValueComponentDTO?
		let rightText: ThemedSizedTextComponentDTO?
		
		required init(body: [String: Any]) {
			self.icon = Self.instantinate(Key.icon, body)
			self.leftText = Self.instantinate(Key.leftText, body)
			self.rightText = Self.instantinate(Key.rightText, body)
			
			super.init(body: body)
		}
	}
}
