//
//  Weekday.swift
//  AlfaStrah
//
//  Created by Darya Viter on 09.09.2021.
//  Copyright © 2021 Redmadrobot. All rights reserved.
//

import Foundation

// sourcery: enumTransformer
enum Weekday: String {
    case monday = "monday"
    case tuesday = "tuesday"
    case wednesday = "wednesday"
    case thursday = "thursday"
    case friday = "friday"
    case saturday = "saturday"
    case sunday = "sunday"

    init(with date: Date) {
        let dateWeekDay = AppLocale.calendar.component(.weekday, from: date)
        let firstWeekday = AppLocale.calendar.firstWeekday

        switch (dateWeekDay - firstWeekday + 7) % 7 {
            case 0: self = Weekday.monday
            case 1: self = Weekday.tuesday
            case 2: self = Weekday.wednesday
            case 3: self = Weekday.thursday
            case 4: self = Weekday.friday
            case 5: self = Weekday.saturday
            case 6: self = Weekday.sunday
            default: fatalError("Weekday is not correct")
        }
    }

    /// Example: monday - "понедельника"
    var declensionOfWeekdayRus: String {
        switch self {
            case .monday: return NSLocalizedString("weekday_monday", comment: "")
            case .tuesday: return NSLocalizedString("weekday_tuesday", comment: "")
            case .wednesday: return NSLocalizedString("weekday_wednesday", comment: "")
            case .thursday: return NSLocalizedString("weekday_thursday", comment: "")
            case .friday: return NSLocalizedString("weekday_friday", comment: "")
            case .saturday: return NSLocalizedString("weekday_saturday", comment: "")
            case .sunday: return NSLocalizedString("weekday_sunday", comment: "")
        }
    }
}
