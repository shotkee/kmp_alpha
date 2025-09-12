//
//  UINavigationBar+.swift
//  AlfaStrah
//
//  Created by Makson on 13.08.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

import Foundation

func updateColorNavigationBar(isSystemNavBarColor: Bool)
{
	UINavigationBar.appearance(whenContainedInInstancesOf: [ UINavigationController.self ]).tintColor = isSystemNavBarColor
		? nil
		: .Icons.iconAccentThemed
	UINavigationBar.appearance(whenContainedInInstancesOf: [ UINavigationController.self ]).backgroundColor = isSystemNavBarColor
		? nil
		: .Background.backgroundContent
}
