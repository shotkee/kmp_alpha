//
//  InfoMessage.swift
//  AlfaStrah
//
//  Created by Makson on 06.08.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

import Foundation

// sourcery: transformer
struct InfoMessage {
	// sourcery: enumTransformer, enumTransformer.type = "String"
	enum MessageType: String {
		// sourcery: enumTransformer.value = "screen"
		case screen = "screen"
		// sourcery: enumTransformer.value = "alert"
		case alert = "alert"
	}
	// sourcery: transformer.name = "type"
	let type: MessageType
	// sourcery: transformer.name = "title"
	let title: String
	// sourcery: transformer.name = "text"
	let text: String
	// sourcery: transformer.name = "icon_themed"
	let icon: ThemedValue?
	
	// sourcery: transformer.name = "actions"
	let actions: [InfoMessage.Action]
}

extension InfoMessage
{
	// sourcery: transformer
	struct Action {
		// sourcery: transformer.name = "title"
		let title: String
		
		// sourcery: enumTransformer, enumTransformer.type = "String"
		enum ActionType: String {
			// sourcery: enumTransformer.value = "close"
			// sourcery: defaultCase
			case close = "close"
			// sourcery: enumTransformer.value = "retry"
			case retry = "retry"
			// sourcery: enumTransformer.value = "chat"
			case chat = "chat"
		}
		
		// sourcery: transformer.name = "action"
		let type: ActionType
		
		// sourcery: transformer.name = "button_text_color_themed"
		let textHexColor: ThemedValue?
		
		// sourcery: transformer.name = "button_color_themed"
		let backgroundHexColor: ThemedValue?
	}
}
