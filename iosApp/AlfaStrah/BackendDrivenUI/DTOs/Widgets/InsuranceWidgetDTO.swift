//
//  InsuranceWidgetDTO.swift
//  AlfaStrah
//
//  Created by vit on 16.04.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

extension BDUI {
	class InsuranceWidgetDTO: WidgetDTO {
		enum Key: String {
			case title = "title"
			case content = "content"
			case footer = "bottom"
		}
		
		let title: ThemedTextComponentDTO?
		let content: [InsuranceContentComponentDTO]?
		let footer: InsuranceFooterWidgetComponentDTO?
		
		required init(body: [String: Any]) {
			self.title = Self.instantinate(Key.title, body)
			self.content = Self.instantinate(Key.content, body)
			self.footer = Self.instantinate(Key.footer, body)
			
			super.init(body: body)
		}
	}
}
