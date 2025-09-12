//
//  SwitchCell.swift
//  AlfaStrah
//
//  Created by Igor Pokrovsky on 24/01/2018.
//  Copyright © 2018 RedMadRobot. All rights reserved.
//

import UIKit
import Legacy

class SwitchCell: UITableViewCell {
    static let id: Reusable<SwitchCell> = .fromNib()

    var title: String? {
        didSet {
			titleLabel <~ Style.Label.primaryHeadline1
            titleLabel.text = title
        }
    }

    var value: Bool = false {
        didSet {
            switchView.isOn = value
        }
    }

    var valueChanged: ((Bool) -> Void)?

    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var switchView: RedSwitch!

    @IBAction private func switchValueChanged() {
        valueChanged?(switchView.isOn)
    }
}
