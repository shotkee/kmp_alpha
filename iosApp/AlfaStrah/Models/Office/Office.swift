//
//  Office.swift
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 16/11/2018.
//  Copyright © 2018 RedMadRobot. All rights reserved.
//

// sourcery: transformer
struct Office: Equatable {
    // sourcery: transformer = IdTransformer<Any>()
    let id: String
    let address: String
    let coordinate: Coordinate
    let phones: [Phone]
    // sourcery: transformer.name = "service_hours"
    let serviceHours: String
    var services: [String]
    // sourcery: transformer.name = "city_id"
    var cityId: String
    var campaigns: String?
    // sourcery: transformer.name = "card_pay"
    var cardPaymentAvailable: Bool
    // sourcery: transformer.name = "make_selling"
    var purchaseActive: Bool
    // sourcery: transformer.name = "make_damage_claim"
    var damageClaimAvailable: Bool
    // sourcery: transformer.name = "make_osago_claim"
    var osagoClaimAvailable: Bool
    // sourcery: transformer.name = "make_telematics_install"
    var telematicsInstallAvailable: Bool
    // sourcery: transformer.name = "damage_claim_text"
    var damageClaimText: String?
    // sourcery: transformer.name = "osago_claim_text"
    var osagoClaimText: String?
    // sourcery: transformer.name = "advert_text"
    var advertText: String?
    // sourcery: transformer.name = "additional_contacts"
    var additionalContacts: String?
    // sourcery: transformer.name = "special_conditions"
    var specialConditions: String?
    var metro: [String]?
    /// (measured in meters)
    var distance: Double?
    var timetable: [OfficeTimetable]
    // sourcery: transformer.name = "special_timetable"
    var specialTimetable: [OfficeSpecialTimetable]

    // Methods and counting parameters

    private var todaySpecialTimeTable: OfficeSpecialTimetable? { specialTimetable.first { AppLocale.calendar.isDateInToday($0.day) } }

    var isWorkToday: Bool { todaySpecialTimeTable?.isWorking ?? timetable.first { $0.day == Weekday(with: Date()) }?.isWorking ?? false }

    func contains(_ searchString: String) -> Bool {
        address.range(of: searchString, options: .caseInsensitive) != nil
            || !phones.filter { $0.plain.range(of: searchString, options: .caseInsensitive) != nil }.isEmpty
            || serviceHours.range(of: searchString, options: .caseInsensitive) != nil
            || !services.filter { $0.range(of: searchString, options: .caseInsensitive) != nil }.isEmpty
            || campaigns?.range(of: searchString, options: .caseInsensitive) != nil
            || damageClaimText?.range(of: searchString, options: .caseInsensitive) != nil
            || osagoClaimText?.range(of: searchString, options: .caseInsensitive) != nil
            || advertText?.range(of: searchString, options: .caseInsensitive) != nil
            || additionalContacts?.range(of: searchString, options: .caseInsensitive) != nil
            || specialConditions?.range(of: searchString, options: .caseInsensitive) != nil
            || !(metro?.filter { $0.range(of: searchString, options: .caseInsensitive) != nil }.isEmpty ?? true)
    }

    func getBreakTime() -> (breakStartTime: String, breakEndTime: String)? {
        let todayTimetable = timetable.first { $0.day == Weekday(with: Date()) }
        let breakStartTime = todaySpecialTimeTable?.officeHours?.breakStartTime
            ?? todayTimetable?.officeHours?.breakStartTime
        let breakEndTime = todaySpecialTimeTable?.officeHours?.breakEndTime
            ?? todayTimetable?.officeHours?.breakEndTime
        guard let breakStartTime = breakStartTime, let breakEndTime = breakEndTime else { return nil }

        return (breakStartTime, breakEndTime)
    }

    func getWorkTimeDates() -> (
        todayStartTime: Date,
        todayCloseTime: Date,
        nextDayStartTime: Date,
        nextWorkWeekDay: Weekday
    )? {
        guard isWorkToday else { return nil }

        let todayTimetable = timetable.first { $0.day == Weekday(with: Date()) }
        let startTime = todaySpecialTimeTable?.officeHours?.startTime ?? todayTimetable?.officeHours?.startTime
        let closeTime = todaySpecialTimeTable?.officeHours?.closeTime ?? todayTimetable?.officeHours?.closeTime
		
        var nextDayDateDelta = DateComponents()
		nextDayDateDelta.setValue(returnNextWorkDayDelta(), for: .day)
		
        guard let startTimeDateHour = AppLocale.timeDate(startTime ?? ""),
              let closeTimeDateHour = AppLocale.timeDate(closeTime ?? ""),
              let nextWorkDay = AppLocale.calendar.date(byAdding: nextDayDateDelta, to: Date()),
              let nextWorkStartTime = timetable.first(where: { $0.day == Weekday(with: nextWorkDay) })?.officeHours?.startTime,
              let nextWorkStartTimeDate = AppLocale.timeDate(nextWorkStartTime)
        else { return nil }

        return (
            todayStartTime: startTimeDateHour,
            todayCloseTime: closeTimeDateHour,
			nextDayStartTime: nextWorkStartTimeDate,
			nextWorkWeekDay: Weekday(with: nextWorkDay)
        )
    }
    
    static func == (lhs: Office, rhs: Office) -> Bool {
        return lhs.id == rhs.id
    }
	
	private func returnNextWorkDayDelta() -> Int? {
		var appendedTimetable: [OfficeTimetable] = []
		
		guard let todayTimetableIndex = timetable.firstIndex(where: { $0.day == Weekday(with: Date()) })
		else { return nil }
	
		let cuttedTimetable = timetable.dropFirst(todayTimetableIndex)
		appendedTimetable.append(contentsOf: cuttedTimetable)
		var appendedTimetableWithNoZeroIndex = appendedTimetable.dropFirst()
		appendedTimetableWithNoZeroIndex.append(contentsOf: timetable)
		let appendedTimetableIndex = appendedTimetableWithNoZeroIndex.firstIndex(where: { $0.isWorking })
		return appendedTimetableIndex
	}
}
