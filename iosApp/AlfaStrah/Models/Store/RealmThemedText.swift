//
//  RealmThemedText.swift
//  AlfaStrah
//
//  Created by vit on 02.07.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

import Foundation
import RealmSwift

class RealmThemedText: RealmEntity {
	@objc dynamic var text: String = ""
	@objc dynamic var themedColor: RealmThemedValue?
}
