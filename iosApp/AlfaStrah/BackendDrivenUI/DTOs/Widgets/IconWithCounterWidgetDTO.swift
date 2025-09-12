//
//  IconWithCounterWidgetDTO.swift
//  AlfaStrah
//
//  Created by vit on 16.07.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

extension BDUI {
	class IconWithCounterWidgetDTO: WidgetDTO {
		enum Key: String {
			case icon = "icon"
			case counter = "counter"
		}
		
		let themedIcon: ThemedValueComponentDTO?
		let counter: CounterComponentDTO?
		
		required init(body: [String: Any]) {
			self.themedIcon = Self.instantinate(Key.icon, body)
			self.counter = Self.instantinate(Key.counter, body)
			
			super.init(body: body)
		}
	}
	
	class CounterComponentDTO: ComponentDTO {
		enum Key: String {
			case backgroundColor = "backgroundColor"
			case count = "count"
		}
		
		let themedBackgroundColor: ThemedValueComponentDTO?
		let themedText: ThemedTextComponentDTO?
		
		required init(body: [String: Any]) {
			self.themedBackgroundColor = Self.instantinate(Key.backgroundColor, body)
			self.themedText = Self.instantinate(Key.count, body)
			
			super.init(body: body)
		}
	}
}
