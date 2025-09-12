//
//  EventReport
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 22/01/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

// sourcery: transformer
struct EventReport {
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

    // DEPRECATED
    // C 27.05.2019 отдается всегда пустой массив
    var files: [FilePreview]?

    // sourcery: transformer.name = "type"
    var eventType: EventType

    var coordinate: Coordinate?

    // sourcery: transformer.name = "insurance_id", transformer = IdTransformer<Any>()
    var insuranceId: String
}
