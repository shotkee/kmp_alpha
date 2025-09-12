//
//  RMRStyledSwitch.swift
//  AlfaStrah
//
//  Created by Olga Vorona on 29/12/15.
//  Copyright © 2015 RedMadRobot. All rights reserved.
//

import UIKit

class RMRStyledSwitch: DGRunkeeperSwitch {
    @objc override var selectedIndex: Int {
        super.selectedIndex
    }

    @objc func style(
        leftTitle: String,
        rightTitle: String,
        titleColor: UIColor = Style.Color.text,
        backgroundColor: UIColor = Style.Color.alternateBackground,
        selectedTitleColor: UIColor = Style.Color.whiteText,
        selectedBackgroundColor: UIColor = Style.Color.main,
        titleFont: UIFont = Style.Font.text,
		selectedBackgroundInset: CGFloat = 1.0
    ) {
        self.leftTitle = leftTitle
        self.rightTitle = rightTitle
        self.backgroundColor = backgroundColor
        self.titleColor = titleColor
        self.selectedTitleColor = selectedTitleColor
        self.selectedBackgroundColor = selectedBackgroundColor
        self.titleFont = titleFont
        self.selectedBackgroundInset = selectedBackgroundInset
    }
}
