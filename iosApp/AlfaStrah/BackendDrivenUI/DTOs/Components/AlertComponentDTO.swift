//
//  AlertComponentDTO.swift
//  AlfaStrah
//
//  Created by vit on 31.10.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

extension BDUI {
	class AlertComponentDTO: ComponentDTO {
		enum Key: String {
			case title = "title"
			case description = "description"
			case buttons = "buttons"
		}
		
		let title: String?
		let description: String?
		let buttons: [AlertButtonComponentDTO]?
		
		required init(body: [String: Any]) {
			self.title = body[Key.title] as? String
			self.description = body[Key.description] as? String
			self.buttons = Self.instantinate(Key.buttons, body)
			
			super.init(body: body)
		}
	}
	
	class AlertButtonComponentDTO: ComponentDTO {
		enum Key: String {
			case title = "title"
			case style = "style"
			case action = "action"
		}
		
		enum AlertStyle: String {
			case cancel = "cancel"
			case destructive = "destructive"
			case `default` = "default"
		}
		
		let title: String?
		let style: AlertStyle?
		let action: ActionDTO?
		
		required init(body: [String: Any]) {
			self.title = body[Key.title] as? String
			self.style = AlertStyle(rawValue: body[Key.style] as? String ?? "")
			self.action = Self.instantinate(Key.action, body)
			
			super.init(body: body)
		}
	}
}
