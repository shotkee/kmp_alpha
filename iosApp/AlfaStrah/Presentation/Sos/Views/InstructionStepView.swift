//
//  InstructionStepView.swift
//  AlfaStrah
//
//  Created by Amir Nuriev on 4/29/19.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import UIKit

class InstructionStepView: UIView {
    @IBOutlet private var numberLabel: UILabel!
    @IBOutlet private var descriptionLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        setupUI()
    }

    private func setupUI() {
        numberLabel <~ Style.Label.primaryHeadline3
    }

    func configure(step: InstructionStep) {
        numberLabel.text = String(format: "%d.", step.sortNumber + 1)
        let descriptionString = NSMutableAttributedString()
        if !step.title.isEmpty {
            let titleString = "\(step.title)\n" <~ Style.TextAttributes.stepTitleText
            descriptionString.append(titleString)
        }
        descriptionString.append(step.fullDescription <~ Style.TextAttributes.normalText)
        descriptionLabel.attributedText = descriptionString
    }
}
