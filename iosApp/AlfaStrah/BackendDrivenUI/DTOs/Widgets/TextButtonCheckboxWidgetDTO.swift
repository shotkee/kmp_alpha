//
//  TextButtonCheckboxWidgetDTO.swift
//  AlfaStrah
//
//  Created by vit on 11.09.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

extension BDUI {
	class TextButtonCheckboxWidgetDTO: WidgetDTO {
		enum Key: String {
			case title = "title"
			case isSelect = "isSelect"
			case lines = "lines"
		}
		
		let themedTitle: ThemedTextComponentDTO?
		let isSelected: Bool
		let textRows: [СopyableThemedTextComponentDTO]?
		
		required init(body: [String: Any]) {
			self.themedTitle = Self.instantinate(Key.title, body)
			self.isSelected = body[Key.isSelect] as? Bool ?? false
			self.textRows = Self.instantinate(Key.lines, body)
			
			super.init(body: body)
		}
	}
}
