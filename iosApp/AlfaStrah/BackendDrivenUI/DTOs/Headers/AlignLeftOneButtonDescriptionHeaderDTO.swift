//
//  AlignLeftOneButtonDescriptionHeaderDTO.swift
//  AlfaStrah
//
//  Created by vit on 16.08.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

extension BDUI {
	class AlignLeftOneButtonDescriptionHeaderDTO: HeaderDTO {
		enum Key: String {
			case title = "title"
			case description = "description"
			case rightButton = "rightButton"
		}
		
		let rightButton: InlineWidgetButtonComponentDTO?
		let themedSizedTitle: ThemedSizedTextComponentDTO?
		let themedSizedDescription: ThemedSizedTextComponentDTO?
		
		required init(body: [String: Any]) {
			self.rightButton = Self.instantinate(Key.rightButton, body)
			self.themedSizedTitle = Self.instantinate(Key.title, body)
			self.themedSizedDescription = Self.instantinate(Key.description, body)
			
			super.init(body: body)
		}
	}
}
