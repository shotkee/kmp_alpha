//
//  BonusPointsData.swift
//  AlfaStrah
//
//  Created by vit on 18.06.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

// sourcery: transformer
struct BonusPointsData: Entity {
	// sourcery: transformer.name = "title"
	let themedTitle: ThemedText?
	// sourcery: transformer.name = "icons"
	let themedIcons: [ThemedValue]
	// sourcery: transformer.name = "bonuses"
	let bonuses: [Bonus]
}

// sourcery: transformer
struct Bonus: Entity {
	// sourcery: transformer.name = "points"
	let points: Points?
	// sourcery: transformer.name = "button"
	let themedButton: ThemedButton?
	// sourcery: transformer.name = "subtitle"
	let themedDescription: ThemedText?
	// sourcery: transformer.name = "title"
	let themedTitle: ThemedText?
	// sourcery: transformer.name = "image"
	let themedImage: ThemedValue?
	// sourcery: transformer.name = "background"
	let themedBackgroundColor: ThemedValue?
	// sourcery: transformer.name = "link"
	let themedLink: ThemedLink?
}

// sourcery: transformer
struct Points: Entity {
	// sourcery: transformer.name = "amount"
	let themedAmount: ThemedText?
	// sourcery: transformer.name = "icon"
	let themedIcon: ThemedValue?
}
