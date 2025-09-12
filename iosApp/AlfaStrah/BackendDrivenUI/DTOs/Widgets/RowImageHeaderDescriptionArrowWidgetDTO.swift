//
//  RowImageHeaderDescriptionArrowWidgetDTO.swift
//  AlfaStrah
//
//  Created by vit on 25.10.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

extension BDUI {
	class RowImageHeaderDescriptionArrowWidgetDTO: WidgetDTO {
		enum Key: String {
			case title = "title"
			case description = "description"
			case amount = "amount"
			case arrow = "arrow"
			case image = "image"
			case icon = "icon"
		}
		
		let title: ThemedSizedTextComponentDTO?
		let description: ThemedSizedTextComponentDTO?
		let amount: ThemedSizedTextComponentDTO?
		let arrow: ArrowComponentDTO?
		let image: ThemedValueComponentDTO?
		let icon: ThemedValueComponentDTO?
		
		required init(body: [String: Any]) {
			self.title = Self.instantinate(Key.title, body)
			self.description = Self.instantinate(Key.description, body)
			self.amount = Self.instantinate(Key.amount, body)
			self.arrow = Self.instantinate(Key.arrow, body)
			self.image = Self.instantinate(Key.image, body)
			self.icon = Self.instantinate(Key.icon, body)
			
			super.init(body: body)
		}
	}
}
