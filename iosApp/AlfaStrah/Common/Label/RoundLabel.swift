//
//  RoundLabel.swift
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 21.12.2020.
//  Copyright © 2020 Redmadrobot. All rights reserved.
//

import UIKit

class RoundMarkLabel: UILabel {
    enum Constants {
        static let defaultSize: CGFloat = 18
    }

    private var circleSize: CGFloat = Constants.defaultSize
    private var borderWidth: CGFloat = 0
    private var widthLayoutConstraint: NSLayoutConstraint?

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        setup()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        setup()
    }

    func configure(
        text: String,
        borderWidth: CGFloat = 0,
        size: CGFloat = Constants.defaultSize,
        backgroundColor: UIColor,
        style: Style.Label.ColoredLabel
    ) {
        self.borderWidth = borderWidth
        circleSize = size
        self.backgroundColor = backgroundColor
        self <~ style
        self.text = text

        let newSize = circleSize + borderWidth
        if abs((widthLayoutConstraint?.constant ?? 0) - newSize) > 0.1 {
            widthLayoutConstraint?.constant = newSize
            layoutSubviews()
        } else {
            update()
        }
    }

    private var lastBoundsHeight: CGFloat = 0

    override func layoutSubviews() {
        super.layoutSubviews()

        if abs(lastBoundsHeight - bounds.height) > 0.1 {
            lastBoundsHeight = bounds.height
            update()
        }
    }

    private func setup() {
        widthLayoutConstraint = widthAnchor.constraint(equalToConstant: circleSize)
        widthLayoutConstraint?.isActive = true
        widthAnchor.constraint(equalTo: heightAnchor).isActive = true

        layer.masksToBounds = true
        layer.borderColor = Style.Color.whiteText.cgColor

        textAlignment = .center
        numberOfLines = 1
        update()
    }

    private func update() {
        guard let widthLayoutConstraint = widthLayoutConstraint else { return }

        layer.cornerRadius = widthLayoutConstraint.constant / 2
        layer.borderWidth = borderWidth
    }

    override func drawText(in rect: CGRect) {
        super.drawText(in: bounds.inset(by: UIEdgeInsets(top: 0, left: 0, bottom: 1, right: 0)))
    }
}
