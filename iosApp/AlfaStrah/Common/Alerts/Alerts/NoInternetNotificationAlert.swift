//
//  NoInternetNotificationAlert.swift
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 27/07/2018.
//  Copyright © 2018 RedMadRobot. All rights reserved.
//

import UIKit

class NoInternetNotificationAlert: BasicNotificationAlert {
    override var unique: Bool {
        true
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }

    override func setupUI() {
        super.setupUI()

        view.backgroundColor = Style.Color.Palette.black
    }
}
