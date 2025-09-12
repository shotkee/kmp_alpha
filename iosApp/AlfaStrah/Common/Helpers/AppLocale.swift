//
//  AppLocale
//  AlfaStrah
//
//  Created by Olga Vorona on 28/12/15.
//  Copyright © 2015 RedMadRobot. All rights reserved.
//

import Foundation

@objc class AppLocale: NSObject {
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMMM yyyy"
        formatter.locale = currentLocale
        return formatter
    }()

    private static let shortDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        formatter.locale = currentLocale
        return formatter
    }()

    private static let rsaSdkDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = currentLocale
        return formatter
    }()

    private static let dateTimeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMMM yyyy, HH:mm"
        formatter.locale = currentLocale
        return formatter
    }()

    private static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.locale = currentLocale
        return formatter
    }()

    private static let chatDateTimeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm dd MMMM"
        formatter.locale = currentLocale
        return formatter
    }()
    
    private static let priceFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = AppLocale.currentLocale
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 0
        return formatter
    }()

    private static let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = AppLocale.currentLocale
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 0
        formatter.groupingSeparator = " "
        return formatter
    }()

    private static let daysFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.calendar = AppLocale.calendar
        formatter.unitsStyle = .full
        return formatter
    }()

    private static let iso8601DateFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = .withInternetDateTime
        return formatter
    }()
    
    private static let timeZoneFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "ZZZZZ"
        formatter.timeZone = TimeZone.current
        return formatter
    }()
    
    private static var monthDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "LLLL"
        formatter.locale = AppLocale.currentLocale
        return formatter
    }()

    class func date(from string: String, formater: DateFormatter = dateFormatter) -> Date? {
        formater.date(from: string)
    }
    
    class func currentTimezoneISO8601() -> String {
        timeZoneFormatter.string(from: Date())
    }

    class func dateFromISO8601(_ string: String?) -> Date? {
        guard let stringDate = string else { return nil }

        return iso8601DateFormatter.date(from: stringDate)
    }
    
    class func iso8601DateToString(_ date: Date) -> String? {
        iso8601DateFormatter.string(from: date)
    }

    @objc class func dateString(_ date: Date) -> String {
        dateFormatter.string(from: date)
    }

    class func shortDateString(_ date: Date) -> String {
        shortDateFormatter.string(from: date)
    }

    class func rsaSdkDateFormatter(_ date: Date) -> String {
        rsaSdkDateFormatter.string(from: date)
    }
    
    @objc class func timeString(_ date: Date) -> String {
        timeFormatter.string(from: date)
    }

    class func dateTimeString(_ date: Date) -> String {
        dateTimeFormatter.string(from: date)
    }

    class func chatDateString(_ date: Date) -> String {
        chatDateTimeFormatter.string(from: date)
    }

    class func price(from number: NSNumber, currencyCode: String? = nil) -> String {
        currencyCode.map { priceFormatter.currencyCode = $0 }
        return priceFormatter.string(from: number) ?? ""
    }

    /// Adding thousand Separator to Int (2358000 => 2 358 000)
    class func formattedNumber(from number: NSNumber) -> String {
        numberFormatter.string(from: number) ?? ""
    }

    class func days(from number: Int) -> String? {
        daysFormatter.string(from: DateComponents(day: number))
    }

    @objc class func timeDate(_ time: String) -> Date? {
        timeFormatter.date(from: time)
    }

    class func dateComponentsOfDay(_ day: Date) -> DateComponents {
        calendar.dateComponents([.day, .month, .year, .hour, .minute], from: day)
    }
    
    class func monthName(from date: Date) -> String {
        return monthDateFormatter.string(from: date)
    }

    /// Return number of days between dates. Specify absolute true to calculate days including to and from dates.
    /// Specify absolute false to calculate days difference to and from dat
    class func daysCount(fromDate: Date, toDate: Date, absolute: Bool) -> Int {
        // Replace the hour (time) of both dates with 00:00
        let date1 = calendar.startOfDay(for: fromDate)
        let date2 = calendar.startOfDay(for: toDate)
        if calendar.isDate(date1, inSameDayAs: date2) {
            return absolute ? 1 : 0
        }
        let daysDifference = calendar.dateComponents([ .day ], from: date1, to: date2).day ?? 0
        return absolute ? abs(daysDifference) + 1 : abs(daysDifference)
    }

    static let calendar: Calendar = {
        var calendar = Calendar.current
        calendar.locale = currentLocale
        return calendar
    }()

    static let utcCalendar: Calendar = {
        var calendar = Calendar.current
        calendar.locale = currentLocale
        guard let timeZone = TimeZone(abbreviation: "UTC") else {
            fatalError("Incorrect TimeZone!")
        }
        calendar.timeZone = timeZone
        return calendar
    }()

    @objc static let currentLocale: Locale = Locale(identifier: "ru_RU")
}
