//
//  TagBLockWidgetDTO.swift
//  AlfaStrah
//
//  Created by vit on 16.04.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

extension BDUI {
	class TagBLockWidgetDTO: WidgetDTO {
		enum Key: String {
			case arrow = "arrow"
			case title = "title"
			case color = "color"
			case tags = "tags"
		}
		
		let title: ThemedTextComponentDTO?
		let accessoryImageThemedColor: ThemedValueComponentDTO?
		let tags: [TagWithIconWidgetDTO]?
		
		required init(body: [String: Any]) {
			self.title = Self.instantinate(Key.title, body)
			self.accessoryImageThemedColor = Self.instantinate(Key.color, body[Key.arrow] as? [String: Any])
			
			self.tags = Self.instantinate(Key.tags, body)
			
			super.init(body: body)
		}
	}
}
