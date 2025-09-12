//
//  CalendarDate.swift
//  AlfaStrah
//
//  Created by Stanislav Rachenko on 11.11.2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import Foundation

final class CalendarDate: Equatable, Comparable {
    static func < (lhs: CalendarDate, rhs: CalendarDate) -> Bool {
        lhs.date < rhs.date
    }

    static func == (lhs: CalendarDate, rhs: CalendarDate) -> Bool {
        lhs.date == rhs.date
    }

    let date: Date
    private lazy var utcStartOfDayDate: Date = {
        AppLocale.utcCalendar.startOfDay(for: date)
    }()

    init(_ date: Date) {
        self.date = date
    }

    convenience init?(_ date: Date?) {
        guard let theDate = date else {
            return nil
        }
        self.init(theDate)
    }

    var utcStartOfDay: CalendarDate {
        CalendarDate(utcStartOfDayDate)
    }

    var utcWeekday: Int {
        AppLocale.utcCalendar.component(.weekday, from: date)
    }

    var utcFirstDayOfTheMonth: CalendarDate {
        guard let resultDate = AppLocale.utcCalendar.date(from: AppLocale.utcCalendar.dateComponents([.year, .month], from: date)) else {
            fatalError("Incorrect calendar data!")
        }
        return CalendarDate(resultDate)
    }

    var utcEndOfDay: CalendarDate {
        guard let resultDate = AppLocale.utcCalendar.date(byAdding: DateComponents(day: 1, second: -1), to: utcStartOfDayDate) else {
            fatalError("Incorrect calendar data!")
        }
        return CalendarDate(resultDate)
    }

    var utcStartOfMonth: CalendarDate {
        guard let result = AppLocale.utcCalendar.date(from: AppLocale.utcCalendar.dateComponents([.year, .month],
                from: utcStartOfDayDate)) else {
            fatalError("Incorrect calendar data!")
        }
        return CalendarDate(result)
    }

    var utcStartOfNextMonth: CalendarDate {
        guard let resultDate = AppLocale.utcCalendar.date(byAdding: DateComponents(month: 1), to: utcStartOfMonth.date) else {
            fatalError("Incorrect calendar data!")
        }
        return CalendarDate(resultDate)
    }

    var utcEndOfMonth: CalendarDate {
        guard let resultDate = AppLocale.utcCalendar.date(byAdding: DateComponents(month: 1, day: -1), to: utcStartOfMonth.date) else {
            fatalError("Incorrect calendar data!")
        }
        return CalendarDate(resultDate)
    }

    var utcStartOfWeek: CalendarDate {
        let calendar = AppLocale.utcCalendar
        guard let weekday = calendar.dateComponents([.weekday], from: utcStartOfDayDate).weekday else {
            fatalError("Incorrect calendar data!")
        }
        let dayOffset: Int
        let firstWeekday = AppLocale.calendar.firstWeekday
        if weekday >= firstWeekday {
            dayOffset = firstWeekday - weekday
        } else {
            dayOffset = -((7 - (firstWeekday - weekday)) % 7)
        }
        guard let resultDate = calendar.date(byAdding: DateComponents(day: dayOffset), to: date) else {
            fatalError("Incorrect calendar data!")
        }
        return CalendarDate(resultDate)
    }

    var utcEndOfWeek: CalendarDate {
        guard let resultDate = AppLocale.utcCalendar.date(byAdding: DateComponents(day: 6), to: utcStartOfWeek.date) else {
            fatalError("Incorrect calendar data!")
        }
        return CalendarDate(resultDate)
    }

    var calendarWeeksInMonth: Int {
        let leftBound = utcStartOfMonth.utcStartOfWeek
        let rightBound = utcEndOfMonth.utcEndOfWeek
        guard let diff = AppLocale.utcCalendar.dateComponents([.day], from: leftBound.date, to: rightBound.date).day else {
            fatalError("Incorrect calendar data!")
        }
        return (diff + 1) / 7
    }

    func inRangeOf(days: UInt, around date: Date) -> Bool {
        let daysDifference = AppLocale.calendar.dateComponents([.day], from: self.date, to: date).day ?? 0
        return abs(daysDifference) <= days
    }

    func dateByAdding(years: Int = 0, months: Int = 0, days: Int = 0) -> CalendarDate? {
        var dateComponent = DateComponents()
        dateComponent.year = years
        dateComponent.month = months
        dateComponent.day = days
        return CalendarDate(AppLocale.calendar.date(byAdding: dateComponent, to: date))
    }
}
