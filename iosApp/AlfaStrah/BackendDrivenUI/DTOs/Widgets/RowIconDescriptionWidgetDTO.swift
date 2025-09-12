//
//  RowIconDescriptionWidgetDTO.swift
//  AlfaStrah
//
//  Created by vit on 16.07.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

extension BDUI {
	class RowIconDescriptionWidgetDTO: WidgetDTO {
		enum Key: String {
			case title = "title"
			case description = "description"
			case icon = "icon"
			case arrow = "arrow"
		}
		
		let themedTitle: ThemedTextComponentDTO?
		let themedDescription: ThemedTextComponentDTO?
		let themedIcon: ThemedValueComponentDTO?
		let arrow: ArrowComponentDTO?
		
		required init(body: [String: Any]) {
			self.themedTitle = Self.instantinate(Key.title, body)
			self.themedDescription = Self.instantinate(Key.description, body)
			self.themedIcon = Self.instantinate(Key.icon, body)
			self.arrow = Self.instantinate(Key.arrow, body)
			
			super.init(body: body)
		}
	}
}
