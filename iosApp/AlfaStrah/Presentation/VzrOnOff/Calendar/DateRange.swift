//
//  DateRange.swift
//  AlfaStrah
//
//  Created by Stanislav Rachenko on 30.10.2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import Foundation

struct DateRange {
    let startDate: CalendarDate
    let finishDate: CalendarDate?

    init(startDate: Date, finishDate: Date?) {
        self.init(startDate: CalendarDate(startDate), finishDate: CalendarDate(finishDate))
    }

    init(startDate: CalendarDate, finishDate: CalendarDate?) {
        self.startDate = finishDate.map { min(startDate, $0) } ?? startDate
        self.finishDate = finishDate.map { max(startDate, $0) }
    }
}
