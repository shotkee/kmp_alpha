//
//  AnalyticsUtils.swift
//  AlfaStrah
//
//  Created by vit on 14.06.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

struct AnalyticsData {
	let sosActivityKind: SOSActivityKind?
	let analyticsUserProfileProperties: [String: String]
	let insuranceId: String
}

func analyticsData(from: InsuranceMain?, for insuranceId: String) -> AnalyticsData? {
	guard let from
	else { return nil }
	
	let insuranceGroupList = from.insuranceGroupList
	
	if let category = insuranceGroupList.flatMap({ $0.insuranceGroupCategoryList }).first(where: {
		$0.insuranceList.contains(where: { $0.id == insuranceId })
	}) {
		if let analyticsUserProfileProperties = category.insuranceList.first(where: {
			$0.authorizedAnalyticsIsAllowed
		})?.analyticsUserProfileProperties,
		   let sosActivityKind = category.sosActivity?.kind {
			return AnalyticsData(
				sosActivityKind: sosActivityKind,
				analyticsUserProfileProperties: analyticsUserProfileProperties,
				insuranceId: insuranceId
			)
		}
	}
	
	return nil
}

func analyticsData(from: InsuranceMain?, for type: InsuranceCategoryMain.CategoryType) -> AnalyticsData? {
	guard let from
	else { return nil }
	
	let insuranceGroupList = from.insuranceGroupList
	
	let categories = insuranceGroupList.flatMap({ $0.insuranceGroupCategoryList }).filter {
		$0.insuranceCategory.type == type
	}
	
	if let category = categories.first(where: { $0.insuranceList.contains(where: { $0.authorizedAnalyticsIsAllowed }) }),
	   let sosActivityKind = category.sosActivity?.kind,
	   let insurance = category.insuranceList.first(where: { $0.authorizedAnalyticsIsAllowed }) {
		return AnalyticsData(
			sosActivityKind: sosActivityKind,
			analyticsUserProfileProperties: insurance.analyticsUserProfileProperties,
			insuranceId: insurance.id
		)
	}
	return nil
}
