//
//  TextInputWidgetDTO.swift
//  AlfaStrah
//
//  Created by vit on 18.11.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

extension BDUI {
	class TextInputWidgetDTO: WidgetDTO {
		enum Key: String {
			case behavior = "behavior"
			case header = "header"
			case borderColor = "borderColor"
			case errorText = "errorText"
			case errorBorderColor = "errorBorderColor"
			case arrow = "arrow"
			case maxInputSize = "maxInputSize"
			case placeholder = "placeholder"
			case input = "input"
			case focusedBorderColor = "focusedBorderColor"
		}
		
		enum State: String {
			case normal = "normal"
			case disabled = "disabled"
		}
		
		let state: State
		
		let floatingTitle: ThemedSizedTextComponentDTO?
		let placeholder: ThemedSizedTextComponentDTO?
		let text: ThemedSizedTextComponentDTO?
		let focusedBorderColor: ThemedValueComponentDTO?
		let error: ThemedSizedTextComponentDTO?
		let errorBorderColor: ThemedValueComponentDTO?
		let maxInputLength: Int?
		let arrow: ArrowComponentDTO?
		
		required init(body: [String: Any]) {
			self.floatingTitle = Self.instantinate(Key.header, body)
			self.placeholder = Self.instantinate(Key.placeholder, body)
			self.text = Self.instantinate(Key.input, body)
			self.error = Self.instantinate(Key.errorText, body)
			self.errorBorderColor = Self.instantinate(Key.errorBorderColor, body)
			self.arrow = Self.instantinate(Key.arrow, body)
			self.maxInputLength = body[Key.maxInputSize] as? Int
			self.focusedBorderColor = Self.instantinate(Key.focusedBorderColor, body)
			
			self.state = State(rawValue: body[Key.behavior] as? String ?? "") ?? .normal
			
			super.init(body: body)
		}
	}
}
