//
//  LocalCalendarService.swift
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 10.09.2018.
//  Copyright © 2018 RedMadRobot. All rights reserved.
//

import Foundation
import EventKit
import Legacy

final class LocalCalendarService: CalendarService {
    private let eventStore = EKEventStore()

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
    ) {
        guard startDate > Date() else { return completion(.failure(.dateInPast)) }

        let createEvent: () -> Void = {
            let event = EKEvent(eventStore: self.eventStore)
            event.startDate = startDate
            event.endDate = endDate
            event.isAllDay = isAllDay
            event.title = title
            event.notes = notes
            event.location = address
            if let locationTitle = locationTitle, let location = location {
                let structuredLocation = EKStructuredLocation(title: locationTitle)
                structuredLocation.geoLocation = location
                event.structuredLocation = structuredLocation
            }
            event.calendar = self.eventStore.defaultCalendarForNewEvents
            do {
                try self.eventStore.save(event, span: .thisEvent)
                completion(.success(()))
            } catch {
                completion(.failure(.error(error)))
            }
        }

        switch EKEventStore.authorizationStatus(for: .event) {
            case .notDetermined:
                eventStore.requestAccess(to: .event) { granted, error in
                    if granted {
                        createEvent()
                    } else if let error = error {
                        completion(.failure(.error(error)))
                    } else {
                        completion(.failure(.accessDenied))
                    }
                }
            case .authorized:
                createEvent()
            case .denied, .restricted:
                completion(.failure(.accessDenied))
            @unknown default:
                completion(.failure(.accessDenied))
        }
    }
}
