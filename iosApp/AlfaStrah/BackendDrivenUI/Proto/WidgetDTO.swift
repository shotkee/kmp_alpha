//
//  WidgetDTO.swift
//  AlfaStrah
//
//  Created by vit on 05.07.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

extension BDUI {
	class WidgetDTO: ComponentDTO {
		enum Key: String {
			case backgroundColor = "backgroundColor"
			case paddingBottom = "paddingBottom"
			case paddingTop = "paddingTop"
			case events = "events"
			case formData = "formData"
		}
		
		let themedBackgroundColor: ThemedValueComponentDTO?
		let paddingTop: CGFloat?
		let paddingBottom: CGFloat?
		
		let events: EventsDTO?
		
		let formData: FormDataEntryComponentDTO?
		
		required init(body: [String: Any]) {
			self.themedBackgroundColor = Self.instantinate(Key.backgroundColor, body)
			self.paddingTop = body[Key.paddingTop] as? CGFloat
			self.paddingBottom = body[Key.paddingBottom] as? CGFloat
			self.events = Self.instantinate(Key.events, body)
			
			self.formData = Self.instantinate(Key.formData, body)
			
			if let formData {
				events?.formDataPatchKey = formData.name
			}
			
			super.init(body: body)
		}
	}
	
	class FormDataEntryComponentDTO: ComponentDTO {
		enum Key: String {
			case name = "name"
			case value = "value"
		}
		
		let name: String?
		let value: Any?
		
		required init(body: [String: Any]) {
			self.name = body[Key.name] as? String
			self.value = body[Key.value]
			
			super.init(body: body)
		}
	}
}
