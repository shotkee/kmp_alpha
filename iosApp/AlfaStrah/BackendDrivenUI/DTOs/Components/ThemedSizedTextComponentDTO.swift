//
//  ThemedSizedTextComponentDTO.swift
//  AlfaStrah
//
//  Created by vit on 19.08.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

extension BDUI {
	class ThemedSizedTextComponentDTO: ComponentDTO {
		enum Key: String {
			case color = "color"
			case text = "text"
			case titleSize = "titleSize"
			case underline = "underline"
			case bold = "bold"
			case italic = "italic"
			case underlineColor = "underlineColor"
		}
		
		enum LineType: String {
			case solid = "Solid"
		}
		
		let themedColor: ThemedValueComponentDTO?
		let text: String?
		let titleSize: CGFloat?
		let underlineType: LineType?
		let underlineColor: ThemedValueComponentDTO?
		
		let isBold: Bool?
		let isItalic: Bool?
		
		required init(body: [String: Any]) {
			self.themedColor = Self.instantinate(Key.color, body)
			self.text = body[Key.text] as? String
			self.titleSize = body[Key.titleSize] as? CGFloat
			self.underlineType = LineType(rawValue: body[Key.underline] as? String ?? "")
			self.underlineColor = Self.instantinate(Key.underlineColor, body)
			self.isBold = body[Key.bold] as? Bool ?? false
			self.isItalic = body[Key.italic] as? Bool ?? false
			
			super.init(body: body)
		}
	}
}
