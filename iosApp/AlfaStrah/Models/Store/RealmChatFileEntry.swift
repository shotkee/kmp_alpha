//
//  RealmChatFileEntry.swift
//  AlfaStrah
//
//  Created by vit on 18.03.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

import Foundation
import RealmSwift

class RealmChatFileEntry: RealmEntity {
	@objc dynamic var id: String = ""
	@objc dynamic var remoteUrlPathBase64Encoded: String = ""
	@objc dynamic var filename: String = ""
	@objc dynamic var expirationDate: Date = Date()
	
	override static func primaryKey() -> String? {
		return "id"
	}
}
