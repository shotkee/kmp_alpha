//
//  RealmMedicalCardFile.swift
//  AlfaStrah
//
//  Created by vit on 22.05.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

import Foundation
import RealmSwift

class RealmMedicalCardFile: RealmEntity {
    @objc dynamic var id: Int64 = 0
    @objc dynamic var creationDate: Date = Date()
    @objc dynamic var name: String = ""
    @objc dynamic var status: String = ""
    @objc dynamic var sizeInBytes: Int = 0
    @objc dynamic var fileExtension: String?
}
