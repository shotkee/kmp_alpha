//
//  AppointmentStatus.swift
//  AlfaStrah
//
//  Created by Makson on 25.11.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

import Foundation

// sourcery: transformer
struct AppointmentStatus
{
	// sourcery: transformer.name = "status_title"
	let statusTitle: String?
	
	// sourcery: transformer.name = "title"
	let title: ThemedText
	
	// sourcery: transformer.name = "background_color"
	let backgroundColor: ThemedValue
}
