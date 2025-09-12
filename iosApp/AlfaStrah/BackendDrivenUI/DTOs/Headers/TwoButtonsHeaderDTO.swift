//
//  TwoButtonsHeaderBDUI.swift
//  AlfaStrah
//
//  Created by vit on 27.08.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

extension BDUI {
	class TwoButtonsHeaderDTO: HeaderDTO {
		enum Key: String {
			case leftButton = "leftButton"
			case title = "title"
			case rightButton = "rightButton"
		}
		
		let leftButton: InlineWidgetButtonComponentDTO?
		let title: ThemedSizedTextComponentDTO?
		let rightButton: InlineWidgetButtonComponentDTO?
		
		required init(body: [String: Any]) {
			self.leftButton = Self.instantinate(Key.leftButton, body)
			self.title = Self.instantinate(Key.title, body)
			self.rightButton = Self.instantinate(Key.rightButton, body)
			
			super.init(body: body)
		}
	}
}
