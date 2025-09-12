//
//  RealmBonusPointsData.swift
//  AlfaStrah
//
//  Created by vit on 19.06.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

import Foundation
import RealmSwift

class RealmBonusPointsData: RealmEntity {
	@objc dynamic var themedTitle: RealmThemedText?
	let themedIcons: List<RealmThemedValue> = .init()
	let bonuses: List<RealmBonus> = .init()
}

class RealmBonus: RealmEntity {
	@objc dynamic var points: RealmPoints?
	@objc dynamic var themedButton: RealmThemedButton?
	@objc dynamic var themedDescription: RealmThemedText?
	@objc dynamic var themedTitle: RealmThemedText?
	@objc dynamic var themedImage: RealmThemedValue?
	@objc dynamic var themedBackgroundColor: RealmThemedValue?
	@objc dynamic var themedLink: RealmThemedLink?
}

class RealmThemedLink: RealmEntity {
	@objc dynamic var url: String?
	@objc dynamic var themedThext: RealmThemedText?
}

class RealmPoints: RealmEntity {
	@objc dynamic var themedAmount: RealmThemedText?
	@objc dynamic var themedIcon: RealmThemedValue?
}

class RealmThemedButton: RealmEntity {
	@objc dynamic var themedTextColor: RealmThemedValue?
	@objc dynamic var themedBackgroundColor: RealmThemedValue?
	@objc dynamic var themedBorderColor: RealmThemedValue?

	@objc dynamic var action: RealmBackendAction?
}

class RealmBackendAction: RealmEntity {
	@objc dynamic var title: String = ""
	@objc dynamic var internalType: String = ""
	@objc dynamic var additionalParameters: Data?
}
