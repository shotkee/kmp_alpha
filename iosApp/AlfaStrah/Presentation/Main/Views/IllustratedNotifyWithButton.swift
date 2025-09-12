//
//  MainNotifyWithButton.swift
//  AlfaStrah
//
//  Created by Eugene Ivanov on 14/03/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import UIKit

class IllustratedNotifyWithButton: UIView {
    @IBOutlet private var illustrationImageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var actionButton: RoundEdgeButton!

    @IBAction func actionClick(_ sender: Any) {
        tapAction?()
    }

    struct Input {
        let text: String
        let buttonTitle: String
    }

    private var tapAction: (() -> Void)?
    private var input: Input!

    func set(input: Input, action: @escaping () -> Void) {
        self.input = input
        tapAction = action
        setupUI()
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        actionButton <~ Style.RoundedButton.redBordered
        illustrationImageView.image = .Illustrations.manWithPhone
        textLabel.textColor = .Text.textSecondary
    }

    func setupUI() {
        actionButton.setTitle(input.buttonTitle, for: .normal)
        textLabel.text = input.text
    }
}
