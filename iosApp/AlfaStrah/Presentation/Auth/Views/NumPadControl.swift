//
//  NumPadControl.swift
//  AlfaStrah
//
//  Created by Sergey Germanovich on 06.11.15.
//  Copyright © 2015 RedMadRobot. All rights reserved.
//

import UIKit

enum NumPadButtonType: Int {
    case button0 = 0
    case button1 = 1
    case button2 = 2
    case button3 = 3
    case button4 = 4
    case button5 = 5
    case button6 = 6
    case button7 = 7
    case button8 = 8
    case button9 = 9
    case buttonRemove = 10
    case buttonWithCustomAction = 11
}

class NumPadControl: UIView {
    var buttonTapped: ((NumPadButtonType) -> Void)?

    @IBInspectable var customTitle: String = " " {
        didSet {
            customButton.setTitle(customTitle, for: .normal)
        }
    }

    @IBOutlet private var numButtons: [UIButton]!
    @IBOutlet private var customButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()

        customButton.titleLabel?.numberOfLines = 0
        customButton.titleLabel?.textAlignment = .center
        numButtons.forEach { button in
            button.tintColor = Style.Color.Palette.whiteGray
            button.setBackgroundImage(UIImage(named: "passcode-tap"), for: .highlighted)
            button.setBackgroundImage(UIImage(named: "passcode"), for: .normal)
            button <~ Style.Button.pinPadButton
        }
    }

    // MARK: - Actions

    @IBAction func buttonPressed(_ sender: UIButton) {
        switch sender.tag {
            case let tag where tag <= 9:
                if let buttonType = NumPadButtonType(rawValue: tag) {
                    buttonTapped?(buttonType)
                }
            case let tag where tag == 10:
                buttonTapped?(.button0)
            case let tag where tag == 11:
                buttonTapped?(.buttonWithCustomAction)
            case let tag where tag == 22:
                buttonTapped?(.buttonRemove)
            default:
                break
        }
    }
}
