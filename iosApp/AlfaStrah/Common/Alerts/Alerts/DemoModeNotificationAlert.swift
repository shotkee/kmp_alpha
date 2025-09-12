//
//  DemoModeNotificationAlert.swift
//  AlfaStrah
//
//  Created by Igor Pokrovsky on 07/09/2018.
//  Copyright © 2018 RedMadRobot. All rights reserved.
//

import UIKit

class DemoModeNotificationAlert: BasicNotificationAlert {
    override var unique: Bool {
        true
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        .default
    }

    override var textColor: UIColor {
        Style.Color.whiteText
    }

    override func setupUI() {
        super.setupUI()

        view.backgroundColor = Style.Color.Palette.black
    }

    @objc init() {
        let text = NSLocalizedString("common_demo_mode_alert", comment: "")
        super.init(title: nil, text: text, sound: nil, action: nil)
    }
}
