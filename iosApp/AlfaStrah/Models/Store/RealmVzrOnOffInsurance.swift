//
//  RealmVzrOnOffInsurance.swift
//  AlfaStrah
//
//  Created by Amir Nuriev on 11/14/19.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import Foundation
import RealmSwift

class RealmVzrOnOffInsurance: RealmEntity {
    @objc dynamic var insuranceId: String = ""
    let activeTripList: List<RealmVzrOnOffTrip> = .init()
}
