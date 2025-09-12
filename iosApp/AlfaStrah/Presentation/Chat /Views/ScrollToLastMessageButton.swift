//
//  ScrollToLastMessageButton.swift
//  AlfaStrah
//
//  Created by Vyacheslav Shakaev on 01.12.2021.
//  Copyright © 2021 Touch Instinct. All rights reserved.
//

import UIKit

class ScrollToLastMessageButton: UIView {
    private let diameter: CGFloat = 48.0
    private let cornerRadius: CGFloat = 22.0
    let button: UIButton = UIButton()

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        commonSetup()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        commonSetup()
    }

    private func commonSetup() {
        self.addSubview(button)

        NSLayoutConstraint.activate(
            NSLayoutConstraint.fill(view: button, in: self)
        )

        button.setBackgroundColor(.Background.backgroundSecondary, forState: .normal)
        button.setBackgroundColor(.States.backgroundSecondaryPressed, forState: .highlighted)

        button.clipsToBounds = true
        button.layer.cornerRadius = cornerRadius

        button.setImage(
            UIImage.Icons.arrowDown,
            for: .normal
        )
        button.tintColor = .Icons.iconAccentThemed

        clipsToBounds = false
        layer.masksToBounds = false
        layer.cornerRadius = cornerRadius
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let path = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).cgPath
        layer.shadowColor = UIColor.Shadow.buttonShadow.cgColor
        layer.shadowPath = path
        layer.shadowOffset = CGSize(width: 0, height: 3)
        layer.shadowOpacity = 1
        layer.shadowRadius = 18
    }

    override var intrinsicContentSize: CGSize {
        CGSize(width: diameter, height: diameter)
    }
    
    // MARK: - Dark Theme Support
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
    
        button.setBackgroundColor(.Background.backgroundSecondary, forState: .normal)
        button.setBackgroundColor(.States.backgroundSecondaryPressed, forState: .highlighted)
        
        layer.shadowColor = UIColor.Shadow.buttonShadow.cgColor
    }
}
