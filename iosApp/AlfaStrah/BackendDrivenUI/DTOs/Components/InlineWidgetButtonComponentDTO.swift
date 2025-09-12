//
//  InlineWidgetButtonComponentDTO.swift
//  AlfaStrah
//
//  Created by vit on 19.08.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

extension BDUI {
	class InlineWidgetButtonComponentDTO: ComponentDTO {
		enum Key: String {
			case events = "events"
			case backgroundColor = "backgroundColor"
			case image = "image"
			case text = "text"
		}
		
		let themedImage: ThemedValueComponentDTO?
		let themedSizedTitle: ThemedSizedTextComponentDTO?
		
		let backgroundColor: ThemedValueComponentDTO?
		
		let events: EventsDTO?
		
		required init(body: [String: Any]) {
			self.backgroundColor = Self.instantinate(Key.backgroundColor, body)
			self.themedImage = Self.instantinate(Key.image, body)
			self.themedSizedTitle = Self.instantinate(Key.text, body)
			
			self.events = Self.instantinate(Key.events, body)
			
			super.init(body: body)
		}
	}
}
