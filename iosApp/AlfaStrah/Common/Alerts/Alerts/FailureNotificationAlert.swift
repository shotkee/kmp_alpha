//
//  FailureNotificationAlert.swift
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 30/08/2018.
//  Copyright © 2018 RedMadRobot. All rights reserved.
//

import UIKit

class FailureNotificationAlert: BasicNotificationAlert {
    override var important: Bool {
        false
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }

    override func setupUI() {
        super.setupUI()

        view.backgroundColor = Style.Color.Palette.black
    }
}
