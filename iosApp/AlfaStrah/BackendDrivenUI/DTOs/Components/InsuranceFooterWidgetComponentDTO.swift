//
//  InsuranceFooterWidgetComponentDTO.swift
//  AlfaStrah
//
//  Created by vit on 23.04.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

extension BDUI {
	class InsuranceFooterWidgetComponentDTO: ComponentDTO {
		enum Key: String {
			case text = "text"
			case icon = "icon"
		}
		
		let text: ThemedTextComponentDTO?
		let themedIcon: ThemedValueComponentDTO?
		
		required init(body: [String: Any]) {
			self.text = Self.instantinate(Key.text, body)
			self.themedIcon = Self.instantinate(Key.icon, body)
			
			super.init(body: body)
		}
	}
}
