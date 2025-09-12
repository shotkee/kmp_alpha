//
//  Campaign.swift
//  AlfaStrah
//
//  Created by Evgeny Ivanov on 29/03/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

// sourcery: transformer
struct Campaign {
    // sourcery: transformer = IdTransformer<Any>()
    var id: String
    var title: String
    var annotation: String

    // sourcery: transformer.name = "full_description"
    var fullDescription: String

    // sourcery: transformer.name = "image_url"
    var imageUrl: String
    // sourcery: transformer = "UrlTransformer<Any>()"
    var url: URL?
    var phone: Phone

    // sourcery: transformer.name = "begin_date", transformer = "TimestampTransformer<Any>(scale: 1)"
    var beginDate: Date

    // sourcery: transformer.name = "end_date", transformer = "TimestampTransformer<Any>(scale: 1)"
    var endDate: Date
}
