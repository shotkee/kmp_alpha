//
//  RowIconsWidgetDTO.swift
//  AlfaStrah
//
//  Created by vit on 15.07.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

extension BDUI {
	class RowIconsWidgetDTO: WidgetDTO {
		enum Key: String {
			case title = "title"
			case icons = "icons"
			case arrow = "arrow"
		}
		
		let title: ThemedTextComponentDTO?
		let icons: [ThemedValueComponentDTO]?
		let arrow: ArrowComponentDTO?
		
		required init(body: [String: Any]) {
			self.title = Self.instantinate(Key.title, body)
			self.icons = Self.instantinate(Key.icons, body)
			self.arrow = Self.instantinate(Key.arrow, body)
			
			super.init(body: body)
		}
	}
}
