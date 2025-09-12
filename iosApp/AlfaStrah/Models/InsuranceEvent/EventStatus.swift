//
//  EventStatus
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 22/01/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

// sourcery: transformer
struct EventStatus {
    // sourcery: transformer = IdTransformer<Any>()
    var id: String

    // sourcery: transformer.name = "sort_number"
    var sortNumber: Int

    // sourcery: transformer = "TimestampTransformer<Any>(scale: 1)"
    var date: Date?

    var decision: EventDecision?

    var passed: Bool

    var stoa: Stoa?

    // sourcery: transformer.name = "image_url", transformer = "UrlTransformer<Any>()"
    var imageUrl: URL

    var title: String

    // sourcery: transformer.name = "short_description"
    var shortDescription: String
}
