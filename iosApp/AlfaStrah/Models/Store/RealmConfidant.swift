//
//  RealmConfidant.swift
//  AlfaStrah
//
//  Created by Makson on 06.08.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

import Foundation
import RealmSwift

class RealmConfidant: RealmEntity {
	@objc dynamic var name: String = ""
	@objc dynamic var phone: RealmPhone?
}

class RealmConfidantBanner: RealmEntity {
	@objc dynamic var title: String = ""
	@objc dynamic var subtitle: String = ""
}
