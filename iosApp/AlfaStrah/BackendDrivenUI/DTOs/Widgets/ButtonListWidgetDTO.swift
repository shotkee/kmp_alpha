//
//  ButtonListWidgetDTO.swift
//  AlfaStrah
//
//  Created by vit on 25.10.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

extension BDUI {
	class ButtonListWidgetDTO: WidgetDTO {
		enum Key: String {
			case dividerColor = "dividerColor"
			case items = "items"
		}
		
		let dividerColor: ThemedValueComponentDTO?
		let items: [ButtonListItemComponentDTO]?
		
		required init(body: [String: Any]) {
			self.dividerColor = Self.instantinate(Key.dividerColor, body)
			self.items = Self.instantinate(Key.items, body)
			
			super.init(body: body)
		}
	}
	
	class ButtonListItemComponentDTO: ComponentDTO {
		enum Key: String {
			case title = "title"
			case icon = "icon"
			case arrow = "arrow"
			case events = "events"
		}
		
		let title: ThemedSizedTextComponentDTO?
		let icon: ThemedValueComponentDTO?
		let arrow: ArrowComponentDTO?
		let events: EventsDTO?
		
		required init(body: [String: Any]) {
			self.title = Self.instantinate(Key.title, body)
			self.icon = Self.instantinate(Key.icon, body)
			self.arrow = Self.instantinate(Key.arrow, body)
			self.events = Self.instantinate(Key.events, body)
			
			super.init(body: body)
		}
	}
}
