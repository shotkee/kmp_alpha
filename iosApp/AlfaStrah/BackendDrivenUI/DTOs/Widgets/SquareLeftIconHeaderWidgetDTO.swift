//
//  SquareLeftIconHeaderWidgetDTO.swift
//  AlfaStrah
//
//  Created by vit on 24.07.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

extension BDUI {
	class SquareLeftIconHeaderWidgetDTO: WidgetDTO {
		enum Key: String {
			case title = "title"
			case leftIcon = "leftIcon"
		}
		
		let themedTitle: ThemedTextComponentDTO?
		let themedLeftIcon: ThemedValueComponentDTO?
		
		required init(body: [String: Any]) {
			self.themedTitle = Self.instantinate(Key.title, body)
			self.themedLeftIcon = Self.instantinate(Key.leftIcon, body)
			
			super.init(body: body)
		}
	}
}
