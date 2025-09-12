//
//  PassengersEventAttachment
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 21/06/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

/// Prepared to be send on server passengers event attachment
struct PassengersEventAttachment: Entity {
    var id: String
    var eventReportId: String
    var documentId: Int
    var filename: String
    var documentsCount: Int
}
