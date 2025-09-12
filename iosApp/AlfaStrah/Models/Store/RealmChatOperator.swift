//
//  RealmChatOperator.swift
//  AlfaStrah
//
//  Created by vit on 03.07.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

import Foundation
import RealmSwift

class RealmChatOperator: RealmEntity {
	@objc dynamic var senderId: String?
	@objc dynamic var requestId: String?
	@objc dynamic var name: String?
	dynamic var rate: RealmProperty<Int?> = .init()
	
	override static func primaryKey() -> String? {
		return "senderId"
	}
}
