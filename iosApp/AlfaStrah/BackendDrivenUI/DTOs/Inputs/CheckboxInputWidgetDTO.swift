//
//  CheckboxInputWidgetDTO.swift
//  AlfaStrah
//
//  Created by vit on 13.11.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

extension BDUI {
	class CheckboxInputWidgetDTO: WidgetDTO {
		enum Key: String {
			case isChecked = "isChecked"
			case checkedColors = "checkedColors"
			case uncheckedColors = "uncheckedColors"
			case canChange = "canChange"
			case title = "title"
		}
		
		let title: ThemedSizedTextComponentDTO?
		let checkedColors: CheckboxColorsComponentDTO?
		let uncheckedColors: CheckboxColorsComponentDTO?
		let canChange: Bool
		let isChecked: Bool
		
		required init(body: [String: Any]) {
			self.title = Self.instantinate(Key.title, body)
			self.checkedColors = Self.instantinate(Key.checkedColors, body)
			self.uncheckedColors = Self.instantinate(Key.uncheckedColors, body)
			
			self.isChecked = body[Key.isChecked] as? Bool ?? false
			self.canChange = body[Key.canChange] as? Bool ?? false
			
			super.init(body: body)
		}
	}
	
	class CheckboxColorsComponentDTO: ComponentDTO {
		enum Key: String {
			case borderColor = "borderColor"
			case backgroundColor = "backgroundColor"
			case tickColor = "tickColor"
		}
		
		let backgroundColor: ThemedValueComponentDTO?
		let borderColor: ThemedValueComponentDTO?
		let tickColor: ThemedValueComponentDTO?
		
		required init(body: [String: Any]) {
			self.backgroundColor = Self.instantinate(Key.backgroundColor, body)
			self.borderColor = Self.instantinate(Key.borderColor, body)
			self.tickColor = Self.instantinate(Key.tickColor, body)
			
			super.init(body: body)
		}
	}
}
