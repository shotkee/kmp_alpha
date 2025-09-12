//
//  RedSwitch.swift
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 20/06/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import UIKit

class RedSwitch: UISwitch {
    init() {
        super.init(frame: .zero)

        prepareAppearance(switchAppearance: RedSwitch.appearance())
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        prepareAppearance(switchAppearance: RedSwitch.appearance())
    }

    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()

        prepareAppearance(switchAppearance: RedSwitch.appearance())
    }

    private func prepareAppearance(switchAppearance: RedSwitch) {
        switchAppearance.onTintColor = iosApp.Style.Color.Palette.red
        switchAppearance.tintColor = iosApp.Style.Color.Palette.whiteGray
    }
}
