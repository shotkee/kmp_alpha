//
//  PushNotificationService
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 05/06/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

protocol PushNotificationService: Updatable {
    func register(
        apnsToken: String,
        deviceToken: String,
        completion: @escaping (Result<Bool, AlfastrahError>) -> Void
    )
    
    func reportPushNotificationEvent(
        _ event: PushNotificationEvent,
        externalNotificationId: String
    )
    
    func registerAppForNotifications()
}

// sourcery: enumTransformer
enum PushNotificationEvent: Int {
    case received = 1
    case opened = 2
}
