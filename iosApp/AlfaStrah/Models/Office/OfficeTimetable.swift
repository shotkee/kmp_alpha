//
//  OfficeTimetable.swift
//  AlfaStrah
//
//  Created by Darya Viter on 09.09.2021.
//  Copyright © 2021 Redmadrobot. All rights reserved.
//

import Foundation

// sourcery: transformer
struct OfficeTimetable {
    // sourcery: enumTransformer
    var day: Weekday
    // sourcery: transformer.name = "is_working"
    var isWorking: Bool
    // sourcery: transformer.name = "office_hours"
    var officeHours: OfficeTimetableHours?
}
