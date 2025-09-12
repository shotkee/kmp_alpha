//
//  PassengersEventResponse
//  AlfaStrah
//
//  Created by Evgeny Ivanov on 04/06/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

// sourcery: transformer
struct PassengersEventResponse {
    // sourcery: transformer = IdTransformer<Any>()
    // sourcery: transformer.name = "event_report_id"
    var eventReportId: String

    // sourcery: transformer.name = "risk_document_list"
    var riskDocumentList: [RiskDocument]
}
