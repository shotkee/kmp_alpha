//
//  EventButtonBackendComponent.swift
//  AlfaStrah
//
//  Created by vit on 16.04.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

extension BDUI {
	class EventButtonComponentDTO: ComponentDTO {
		enum Key: String {
			case text = "text"
			case events = "events"
		}
		
		let themedText: ThemedTextComponentDTO?
		let events: EventsDTO?
		
		required init(body: [String: Any]) {
			self.themedText = Self.instantinate(Key.text, body)
			
			self.events = Self.instantinate(Key.events, body)
			
			super.init(body: body)
		}
	}
}
