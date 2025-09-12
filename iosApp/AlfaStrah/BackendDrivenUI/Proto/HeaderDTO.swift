//
//  HeaderDTO.swift
//  AlfaStrah
//
//  Created by vit on 16.08.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

extension BDUI {
	class HeaderDTO: ComponentDTO {
		enum Key: String {
			case backgroundColor = "backgroundColor"
			case event = "events"
		}
		
		let themedBackgroundColor: ThemedValueComponentDTO?
		let events: EventsDTO?
		
		required init(body: [String: Any]) {
			self.themedBackgroundColor = Self.instantinate(Key.backgroundColor, body)
			self.events = Self.instantinate(Key.event, body)
			
			super.init(body: body)
		}
	}
}
