//
//  CreateAutoEventReport
//  AlfaStrah
//
//  Created by Eugene Ivanov on 03/06/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

// sourcery: transformer
struct CreateAutoEventReport {
    // sourcery: transformer.name = "insurance_id"
    var insuranceId: String
    // sourcery: transformer.name = "full_description"
    var fullDescription: String
    var coordinate: Coordinate
    // sourcery: transformer.name = "document_count"
    var documentCount: Int
    // sourcery: transformer.name = "claim_date"
    // sourcery: transformer = "DateTransformer<Any>(format: "yyyy-MM-dd HH:mm:ss", locale: AppLocale.currentLocale)"
    var claimDate: Date
    // sourcery: transformer = "DateTransformer<Any>(format: "xxx", locale: AppLocale.currentLocale)"
    var timezone: Date
    // sourcery: transformer.name = "geo_place"
    var geoPlace: GeoPlace?
}
