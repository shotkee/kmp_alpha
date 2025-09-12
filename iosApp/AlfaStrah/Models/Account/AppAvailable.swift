//
//  AppAvailable
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 11/09/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

// sourcery: transformer
struct AppAvailable {
    var status: AppAvailable.AvailabilityStatus
    var message: String?
    var title: String?
    var link: String?

    // sourcery: enumTransformer
    enum AvailabilityStatus: Int {
        case fullyAvailable = 0
        // sourcery: defaultCase
        case partlyBlocked = 1
        case totalyBlocked = 2
    }
}
