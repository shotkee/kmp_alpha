//
//  ThemedLink.swift
//  AlfaStrah
//
//  Created by vit on 21.06.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

// sourcery: transformer
struct ThemedLink: Entity {
	// sourcery: transformer.name = "url", transformer = "UrlTransformer<Any>()"
	let url: URL?
	// sourcery: transformer.name = "title"
	let themedText: ThemedText?
}
