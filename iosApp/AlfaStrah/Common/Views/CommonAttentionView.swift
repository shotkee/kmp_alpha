//
//  CommonAttentionView.swift
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 23/07/2018.
//  Copyright © 2018 RedMadRobot. All rights reserved.
//

import UIKit

class CommonAttentionView: UIView {
    private var messageLabel: UILabel = UILabel()
    private var appearance: Appearance = .yellow
    private var message: String = ""

    struct Appearance {
        let textColor: UIColor
        let backgroundColor: UIColor

		static let yellow = Appearance(textColor: .Text.textSecondary, backgroundColor: .Background.backgroundTertiary)
		static let gray = Appearance(textColor: .Text.textSecondary, backgroundColor: .Background.background)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        setup()
    }

    private func setup() {
        messageLabel.font = Style.Font.subhead
        messageLabel.numberOfLines = 0
        addSubview(messageLabel)
        NSLayoutConstraint.activate(NSLayoutConstraint.fill(view: messageLabel, in: self,
            margins: UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)))

        updateUI()
    }

    private func updateUI() {
        messageLabel.textColor = appearance.textColor
        messageLabel.text = message
        backgroundColor = appearance.backgroundColor
    }

    func set(message: String, appearance: Appearance) {
        self.message = message
        self.appearance = appearance

        updateUI()
    }
}
