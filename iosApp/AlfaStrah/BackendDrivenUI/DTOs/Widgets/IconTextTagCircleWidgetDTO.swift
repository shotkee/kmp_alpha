//
//  IconTextTagCircleWidgetDTO.swift
//  AlfaStrah
//
//  Created by vit on 14.11.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

extension BDUI {
	class IconTextTagCircleWidgetDTO: WidgetDTO {
		enum Key: String {
			case iconTop = "iconTop"
			case title = "title"
			case description = "description"
			case iconRight = "iconRight"
			case tags = "tags"
		}
		
		let iconTop: ThemedValueComponentDTO?
		let title: ThemedSizedTextComponentDTO?
		let descirption: ThemedSizedTextComponentDTO?
		let iconRight: ThemedValueComponentDTO?
		let tags: [WidgetDTO]?
		
		required init(body: [String: Any]) {
			self.iconTop = Self.instantinate(Key.iconTop, body)
			self.title = Self.instantinate(Key.title, body)
			self.descirption = Self.instantinate(Key.description, body)
			self.iconRight = Self.instantinate(Key.iconRight, body)
			self.tags = Self.instantinate(Key.tags, body)
			
			super.init(body: body)
		}
	}
}
