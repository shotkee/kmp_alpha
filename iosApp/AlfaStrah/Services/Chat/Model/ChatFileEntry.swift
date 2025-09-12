//
//  ChatFileEntry.swift
//  AlfaStrah
//
//  Created by vit on 18.03.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

struct ChatFileEntry: Entity, Equatable {
	let id: String
	let remoteUrlPathBase64Encoded: String
	let filename: String
	let expirationDate: Date
}
