//
//  Endpoints.swift
//  AlfaStrah
//
//  Created by vit on 28.07.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

import Foundation

// sourcery: transformer
struct Endpoints {
    // sourcery: transformer.name = "medicalfilestorage"
    let medicalCardFileServerDomainString: String?
    // sourcery: transformer.name = "cascana"
    let cascanaChatServiceDomainString: String?
	// sourcery: transformer.name = "bdui-mainpage"
	let mainPagePathBDUI: String?
	// sourcery: transformer.name = "bdui-products"
	let productsPathBDUI: String?
	// sourcery: transformer.name = "bdui-profile"
	let profilePathBDUI: String?
	// sourcery: transformer.name = "bdui-bonuses"
	let loyaltyPathBDUI: String?
	// sourcery: transformer.name = "bdui-eventreport-osago"
	let eventReportOsagoPathBDUI: String?
	
	var medicalCardFileServerDomain: String {
		return medicalCardFileServerDomainString ?? "b2b.alfastrah.ru"
	}
	
	var cascanaChatServiceDomain: String {
		return cascanaChatServiceDomainString ?? "caspre.alfastrah.ru"
	}
	
	var mainPageUrlBDUI: URL? {
		return URL(string: mainPagePathBDUI ?? "https://alfa-v3.entelis.team/bdui/start")
	}
	
	var productsUrlBDUI: URL? {
		return URL(string: productsPathBDUI ?? "https://alfa-v3.entelis.team/bdui/products")
	}
	
	var profileUrlBDUI: URL? {
		return URL(string: productsPathBDUI ?? "https://alfa-v3.entelis.team/bdui/profile")
	}
	
	var loyaltyUrlBDUI: URL? {
		return URL(string: productsPathBDUI ?? "https://alfa-v3.entelis.team/bdui/bonuses")
	}
}
