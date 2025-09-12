//
//  NotificationAlert.swift
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 27/07/2018.
//  Copyright © 2018 RedMadRobot. All rights reserved.
//

import UIKit

/// Notification alert identity.
@objc class NotificationAlertIdentity: NSObject {
    var id: String

    init(id: String) {
        self.id = id

        super.init()
    }

    override func isEqual(_ object: Any?) -> Bool {
        id == (object as? NotificationAlertIdentity)?.id
    }
}

/// Notification alert protocol.
@objc protocol NotificationAlert {
    var unique: Bool { get }
    var sound: String? { get }
    var view: UIView { get }
    var preferredStatusBarStyle: UIStatusBarStyle { get }
    var hideAction: (() -> Void)? { get set }
    var important: Bool { get }
}
