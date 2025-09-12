//
//  RealmMedicalCardFileEntry.swift
//  AlfaStrah
//
//  Created by vit on 29.05.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

import Foundation
import RealmSwift

class RealmMedicalCardFileEntry: RealmEntity {
    @objc dynamic var id: String = ""
    @objc dynamic var status: String = ""
    @objc dynamic var localStorageFilename: String?
    @objc dynamic var originalFilename: String = ""
    @objc dynamic var creationDate: Date = Date()
    @objc dynamic var sizeInBytes: Int = 0
    @objc dynamic var fileExtension: String?
    dynamic var fileId: RealmProperty<Int64?> = .init()
	@objc dynamic var errorType: String?
    
    override static func primaryKey() -> String? {
        return "id"
    }
}
