//
//  CalendarService.swift
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 10.09.2018.
//  Copyright © 2018 RedMadRobot. All rights reserved.
//

import Foundation
import Legacy
import CoreLocation

enum CalendarServiceError: Error {
    case accessDenied
    case dateInPast
    case error(Error)
}

protocol CalendarService {
    func createEvent(
        title: String,
        notes: String?,
        startDate: Date,
        endDate: Date,
        isAllDay: Bool,
        locationTitle: String?,
        address: String?,
        location: CLLocation?,
        completion: @escaping (Result<Void, CalendarServiceError>) -> Void
    )
}
