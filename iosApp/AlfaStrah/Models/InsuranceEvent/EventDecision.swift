//
//  EventDecision
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 22/01/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

// sourcery: transformer
struct EventDecision {
    // sourcery: transformer = IdTransformer<Any>()
    var id: String

    var sum: Money?

    // sourcery: transformer = IdTransformer<Any>()
    var number: String

    // sourcery: transformer.name = "url", transformer = "UrlTransformer<Any>()"
    var decisionUrl: URL

    // sourcery: enumTransformer
    enum Resolution: Int {
        // sourcery: defaultCase
        case toTheServiceStation = 1
        case cashCompensation = 2
        case reject = 3
    }

    var resolution: EventDecision.Resolution
}
