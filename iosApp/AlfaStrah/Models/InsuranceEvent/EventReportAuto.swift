//
//  EventReportAuto
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 22/01/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

// sourcery: transformer
struct EventReportAuto {
    // sourcery: transformer = IdTransformer<Any>()
    var id: String

    // sourcery: transformer = IdTransformer<Any>()
    var number: String

    // sourcery: transformer.name = "date", transformer = "TimestampTransformer<Any>(scale: 1)"
    var createDate: Date

    // sourcery: transformer.name = "sent_date", transformer = "TimestampTransformer<Any>(scale: 1)"
    var sentDate: Date

    // sourcery: transformer.name = "full_description"
    var fullDescription: String?

    var files: [FilePreview]?

    // sourcery: transformer.name = "type"
    var eventType: EventType

    var coordinate: Coordinate?

    // sourcery: transformer.name = "insurance_id", transformer = IdTransformer<Any>()
    var insuranceId: String

    // sourcery: transformer.name = "is_opened"
    var isOpened: Bool
	
	// sourcery: transformer.name = "documents"
	var documents: [EventReportAutoDocument]

    var address: String?

    var requisites: String?

    var statuses: [EventStatus]

    var currentStatus: EventStatus? {
        statuses.max { $0.sortNumber < $1.sortNumber }
    }

    var displayDate: Date {
        currentStatus?.date ?? createDate
    }
}

// sourcery: transformer
struct EventReportAutoDocument
{
	// sourcery: transformer.name = "title"
	var title: String
	
	// sourcery: transformer.name = "url", transformer = "UrlTransformer<Any>()"
	var url: URL
}
