//
//  OneButtonHeaderDTO.swift
//  AlfaStrah
//
//  Created by vit on 16.04.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

extension BDUI {
	class OneButtonHeaderDTO: HeaderDTO {
		enum Key: String {
			case leftButton = "leftButton"
			case title = "title"
		}
		
		let leftButton: ScreenNavigationButtonComponentDTO?
		let title: ThemedTextComponentDTO?
		
		required init(body: [String: Any]) {
			self.leftButton = Self.instantinate(Key.leftButton, body)
			self.title = Self.instantinate(Key.title, body)
			
			super.init(body: body)
		}
	}
}
