//
//  RealmVzrOnOffTrip.swift
//  AlfaStrah
//
//  Created by Amir Nuriev on 11/14/19.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import Foundation
import RealmSwift

class RealmVzrOnOffTrip: RealmEntity {
    @objc dynamic var id: String = ""
    @objc dynamic var startDate: Date = Date()
    @objc dynamic var endDate: Date = Date()
    @objc dynamic var days: Int = 0
    dynamic var status: RealmProperty<Int?> = .init()
}
