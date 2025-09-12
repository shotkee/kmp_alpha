//
//  ClinicResponse.swift
//  AlfaStrah
//
//  Created by Makson on 23.10.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

import Foundation

// sourcery: transformer
struct ClinicResponse
{
	// sourcery: transformer.name = "clinic_list"
	let clinicList: [Clinic]
	
	// sourcery: transformer.name = "city_list"
	let cityList: [ClinicWithMetro]
	
	// sourcery: transformer.name = "filter_list"
	let filterList: [ClinicFilter]
}
