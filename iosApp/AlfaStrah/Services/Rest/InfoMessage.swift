//
//  InfoMessage.swift
//  AlfaStrah
//
//  Created by vit on 18.09.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

// sourcery: transformer
struct InfoMessage {
	// sourcery: transformer.name = "actions"
	let actions: [InfoMessageAction]?
	// sourcery: transformer.name = "type"
	let type: InfoMessageType?
	// sourcery: transformer.name = "icon_themed"
	let themedIcon: ThemedValue?
	// sourcery: transformer.name = "title"
	let titleText: String?
	// sourcery: transformer.name = "text"
	let desciptionText: String?
}

// sourcery: enumTransformer, enumTransformer.type = "String"
enum InfoMessageType: String {
	// sourcery: enumTransformer.value = "screen"
	case screen = "screen"
	// sourcery: enumTransformer.value = "alert"
	case alert = "alert"
	// sourcery: enumTransformer.value = "popup"
	case popup = "popup"
}

// sourcery: transformer
struct InfoMessageAction {
	// sourcery: transformer.name = "title"
	let titleText: String?
	// sourcery: transformer.name = "button_color_themed"
	let themedBackgroundColor: ThemedValue?
	// sourcery: transformer.name = "button_text_color_themed"
	let themedTextColor: ThemedValue?
	// sourcery: transformer.name = "action"
	let type: InfoMessageActionType
}

// sourcery: enumTransformer, enumTransformer.type = "String"
enum InfoMessageActionType: String {
	// sourcery: enumTransformer.value = "close"
	case close = "close"
	// sourcery: enumTransformer.value = "retry"
	case retry = "retry"
	// sourcery: enumTransformer.value = "chat"
	case toChat = "chat"
}
