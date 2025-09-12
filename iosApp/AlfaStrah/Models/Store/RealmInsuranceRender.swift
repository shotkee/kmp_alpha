//
//  RealmInsuranceRender.swift
//  AlfaStrah
//
//  Created by vit on 27.05.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

import Foundation
import RealmSwift

class RealmInsuranceRender: RealmEntity {
	@objc dynamic var method: String = ""
	@objc dynamic var postBody: String?
	@objc dynamic var type: String = ""
	@objc dynamic var url: String?
	let headers: List<RealmInsuranceRenderHeader> = .init()
}

class RealmInsuranceRenderHeader: RealmEntity {
	@objc dynamic var value: String = ""
	@objc dynamic var name: String = ""
}
