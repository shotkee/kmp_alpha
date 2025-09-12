//
//  RealmAnalyticsInsuranceProfile.swift
//  AlfaStrah
//
//  Created by vit on 13.06.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

import Foundation
import RealmSwift

class RealmAnalyticsInsuranceProfile: RealmEntity {
	@objc dynamic var insurerFirstname: String = ""
	@objc dynamic var groupName: String = ""
}
