//
//  InsuranceEvent
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 22/01/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

// sourcery: transformer
struct InsuranceEvent {
    // sourcery: transformer = IdTransformer<Any>()
    var id: String

    var report: EventReport
}
