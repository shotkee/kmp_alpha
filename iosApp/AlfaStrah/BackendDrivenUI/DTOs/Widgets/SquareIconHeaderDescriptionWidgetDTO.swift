//
//  SquareIconHeaderDescriptionWidgetDTO.swift
//  AlfaStrah
//
//  Created by vit on 16.04.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

extension BDUI {
	class SquareIconHeaderDescriptionWidgetDTO: WidgetDTO {
		enum Key: String {
			case title = "title"
			case leftIcon = "leftIcon"
			case rightIcon = "rightIcon"
			case description = "description"
		}
		
		let title: ThemedTextComponentDTO?
		let leftThemedIcon: ThemedValueComponentDTO?
		let rightThemedIcon: ThemedValueComponentDTO?
		let description: ThemedTextComponentDTO?
		
		required init(body: [String: Any]) {
			self.title = Self.instantinate(Key.title, body)
			self.leftThemedIcon = Self.instantinate(Key.leftIcon, body)
			self.rightThemedIcon = Self.instantinate(Key.rightIcon, body)
			self.description = Self.instantinate(Key.description, body)
			
			super.init(body: body)
		}
	}
}
