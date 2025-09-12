//
//  AccidentEventAttachment
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 18.11.2020.
//  Copyright © 2020 Redmadrobot. All rights reserved.
//

/// Prepared to be send on server accident event attachment
struct AccidentEventAttachment: Entity, Hashable {
    var id: String
    var eventReportId: String
    var filename: String
}
