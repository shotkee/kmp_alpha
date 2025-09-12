//
//  DmsCostRecoveryWarningBannerView.swift
//  AlfaStrah
//
//  Created by vit on 03.02.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

import UIKit
import Legacy

class DmsCostRecoveryWarningBannerView: UIView {
    private enum Constants {
        static let defaultStartBannerOffset: CGFloat = UIScreen.main.bounds.height
        static let animationDuration: CGFloat = 0.25
    }
    
    // MARK: Outlets
    @IBOutlet private var containerView: UIView!
    @IBOutlet private var closeButton: UIButton!
    @IBOutlet private var textLabel: UILabel!
    
    private var animationIsStarted: Bool = false
    
    // MARK: Actions
    @IBAction private func closeButtonTap(_ sender: Any) {
        dismiss()
    }
    
    // MARK: UIPanGestureRecognizer
    private lazy var panGestureRecognizer = UIPanGestureRecognizer(
        target: self,
        action: #selector(handleDrag(_:))
    )
    
    private var startBannerOffset: CGFloat?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        addGestureRecognizer(panGestureRecognizer)
        setupUI()
        updateUI()
    }
    
    private func setupUI() {
        containerView.layer.cornerRadius = 6
    }
    
    func set(
        appearance: Appearance = .gray,
        text: String,
        startBannerOffset: CGFloat
    ) {
        self.appearance = appearance
        self.textLabel.text = text
        self.startBannerOffset = startBannerOffset
        
        updateUI()
    }
    
    private var appearance: Appearance = .gray
    
    // MARK: Appearance
    struct Appearance {
        let backgroundColor: UIColor
        let closeIconColor: UIColor
        let textStyle: Style.Label.ColoredLabel
        
        static let gray: Appearance = Appearance(
            backgroundColor: Style.Color.Palette.gray,
            closeIconColor: Style.Color.Palette.white,
            textStyle: Style.Label.contrastSubhead
        )
    }
    
    private func updateUI() {
        containerView.backgroundColor = appearance.backgroundColor
        closeButton.tintColor = appearance.closeIconColor
        
        textLabel <~ appearance.textStyle
    }
    
    @objc private func handleDrag(_ recognizer: UIPanGestureRecognizer) {
        let velocity = recognizer.velocity(in: superview)
        
        if velocity.y < 0 && !animationIsStarted {
            dismiss()
        }
    }
    
    @objc private func dismiss() {
        animationIsStarted = true
        
        UIView.animate(
            withDuration: Constants.animationDuration,
            delay: 0,
            options: .curveEaseInOut,
            animations: {
                self.transform = CGAffineTransform(
                    translationX: 0,
                    y: self.startBannerOffset ?? Constants.defaultStartBannerOffset
                )
            },
            completion: { _ in
                self.animationIsStarted = false
                self.removeFromSuperview()
            }
        )
    }
}
