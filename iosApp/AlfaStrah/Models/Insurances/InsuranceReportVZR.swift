//
//  InsuranceReportVZR.swift
//  AlfaStrah
//
//  Created by Makson on 13.11.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

import Foundation

// sourcery: transformer
struct InsuranceReportVZR: Entity {
    // sourcery: transformer.name = "event_report_id"
    let id: Int64
    // sourcery: transformer.name = "title"
    let title: String
    // sourcery: transformer.name = "title_date"
    let dateString: String
    // sourcery: transformer.name = "title_number"
    let numberNofication: String
    // sourcery: transformer.name = "status"
    let status: String
    // sourcery: transformer.name = "status_color"
    let statusColor: String?
	// sourcery: transformer.name = "status_color_themed"
	let statusColorThemed: ThemedValue?
}

// sourcery: transformer
struct InsuranceReportVZRDetailed: Entity {
    // sourcery: transformer.name = "title"
    let title: String
    // sourcery: transformer.name = "status"
    let status: String
    // sourcery: transformer.name = "status_color"
    let statusColor: String?
	// sourcery: transformer.name = "status_color_themed"
	let statusColorThemed: ThemedValue?
    // sourcery: transformer.name = "description"
    let description: String?
    // sourcery: transformer.name = "detailed_content"
    let detailedContent: [FieldList]
    // sourcery: transformer.name = "redirect_url", transformer = "UrlTransformer<Any>()"
    let url: URL?
}

// sourcery: transformer
struct FieldList: Entity {
    // sourcery: transformer.name = "title"
    let title: String
    // sourcery: transformer.name = "value"
    let value: String
}
