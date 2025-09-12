//
//  RightTopIconComponentDTO.swift
//  AlfaStrah
//
//  Created by vit on 22.07.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

extension BDUI {
	class RightTopIconComponentDTO: ComponentDTO {
		enum Key: String {
			case image = "image"
			case event = "events"
		}
		
		let themedIcon: ThemedValueComponentDTO?
		let events: EventsDTO?
		
		required init(body: [String: Any]) {
			self.themedIcon = Self.instantinate(Key.image, body)
			self.events = Self.instantinate(Key.event, body)
			
			super.init(body: body)
		}
	}
}
