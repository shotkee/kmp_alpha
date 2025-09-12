//
//  ClinicWithMetro.swift
//  AlfaStrah
//
//  Created by Makson on 22.10.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

import Foundation

// sourcery: transformer
struct ClinicWithMetro
{
	// sourcery: transformer.name = "id"
	let id: Int
	
	// sourcery: transformer.name = "title"
	let title: String
	
	// sourcery: transformer.name = "longitude"
	let longitude: String
	
	// sourcery: transformer.name = "latitude"
	let latitude: String
	
	// sourcery: transformer.name = "radius"
	let radius: Double
	
	// sourcery: transformer.name = "metro_station_list"
	let metroStationList: [MetroStation]
}

// sourcery: transformer
struct MetroStation
{
	// sourcery: transformer.name = "id"
	let id: Int
	
	// sourcery: transformer.name = "title"
	let title: String
	
	// sourcery: transformer.name = "point_color"
	let pointColor: ThemedValue
	
	// sourcery: transformer.name = "clinic_count"
	let clinicCount: Int?
	
	// sourcery: transformer.name = "longitude"
	let longitude: String
	
	// sourcery: transformer.name = "latitude"
	let latitude: String
}
