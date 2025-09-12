//
//  IconTitleDescriptionArrowWidgetDTO.swift
//  AlfaStrah
//
//  Created by vit on 15.11.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

extension BDUI {
	class IconTitleDescriptionArrowWidgetDTO: WidgetDTO {
		enum Key: String {
			case title = "title"
			case arrow = "arrow"
			case topIcon = "topIcon"
			case description = "description"
		}
		
		let title: [ThemedSizedTextComponentDTO]?
		let arrow: ArrowComponentDTO?
		let description: ThemedSizedTextComponentDTO?
		let topIcon: ThemedValueComponentDTO?
		
		required init(body: [String: Any]) {
			self.title = Self.instantinate(Key.title, body)
			self.arrow = Self.instantinate(Key.arrow, body)
			self.description = Self.instantinate(Key.description, body)
			self.topIcon = Self.instantinate(Key.topIcon, body)
			
			super.init(body: body)
		}
	}
}
