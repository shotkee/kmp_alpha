//
//  SelectClinicFilter.swift
//  AlfaStrah
//
//  Created by Makson on 31.10.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

import Foundation

struct SelectClinicFilter
{
	var selectCityId: Int?
	var selectCityName: String?
	var selectMetroStations: [MetroStation]
	var selectedFilters: [String: [String]]
	
	init(
		selectCityId: Int? = nil,
		selectCityName: String? = nil,
		selectMetroStations: [MetroStation] = [],
		selectedFilters: [String: [String]] = [:]
	) {
		self.selectCityId = selectCityId
		self.selectCityName = selectCityName
		self.selectMetroStations = selectMetroStations
		self.selectedFilters = selectedFilters
	}
	
	var isEmpty: Bool
	{
		return self.selectCityId == nil
			&& self.selectCityName == nil
			&& self.selectMetroStations.isEmpty
			&& self.selectedFilters.isEmpty
	}
}
