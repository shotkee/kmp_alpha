//
//  AlertView.swift
//  AlfaStrah
//
//  Created by Vitaly Shkinev on 17.11.2022.
//  Copyright © 2022 Touch Instinct. All rights reserved.
//

import UIKit
import Legacy

class StateInfoBannerView: UIView {
    private enum Constants {
        static let defaultStartBannerOffset: CGFloat = UIScreen.main.bounds.height
        static let duration: CGFloat = 0.25
    }
    
    // MARK: Outlets
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let containerView = UIView()
    private let iconImageView = UIImageView()
    private let backgroundButton = UIButton()
    private let closeButton = UIButton(type: .system)
    private let contentStackView = UIStackView()
    
    private var animationIsStarted: Bool = false
    private var timer: Timer?
        
    // MARK: UIPanGestureRecognizer
    private lazy var panGestureRecognizer = UIPanGestureRecognizer(
        target: self,
        action: #selector(handleDrag(_:))
    )

    private var startBannerOffset: CGFloat?

    override init(frame: CGRect) {
        super.init(frame: frame)

        addGestureRecognizer(panGestureRecognizer)
        setupUI()
        updateUI(
            hasCloseButton: true,
            iconImage: nil,
            titleFont: Style.Font.text
        )
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    private func setupUI() {
        containerView.layer.cornerRadius = 9
        
        clipsToBounds = false
		backgroundColor = .clear
        
        setupContainerView()
        setupIconImageView()
        setupContentStackView()
        setupBackgroundButton()
        setupCloseButton()
        setupContentLabels()
    }
    
    private func setupContainerView() {
		let cardView = containerView.embedded(hasShadow: true, cornerRadius: 9, shadowStyle: .shadow100pct)
		
        addSubview(cardView)
                
		cardView.translatesAutoresizingMaskIntoConstraints = false
		
		NSLayoutConstraint.activate(NSLayoutConstraint.fill(view: cardView, in: self))
    }
    
    private func setupIconImageView() {
        containerView.addSubview(iconImageView)
        
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            iconImageView.widthAnchor.constraint(equalToConstant: 24),
            iconImageView.heightAnchor.constraint(equalTo: iconImageView.widthAnchor),
            iconImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 14),
            iconImageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            iconImageView.bottomAnchor.constraint(lessThanOrEqualTo: containerView.bottomAnchor, constant: -14)
        ])
        
        iconImageView.backgroundColor = .clear
        iconImageView.contentMode = .center
    }
    
    private func setupContentStackView() {
        containerView.addSubview(contentStackView)
        
        contentStackView.isLayoutMarginsRelativeArrangement = true
        contentStackView.layoutMargins = .zero
        contentStackView.alignment = .fill
        contentStackView.distribution = .fill
        contentStackView.axis = .vertical
        contentStackView.spacing = 2
        contentStackView.backgroundColor = .clear
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            contentStackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 14),
            contentStackView.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 12),
            contentStackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -14)
        ])
    }
    
    private func setupBackgroundButton() {
        containerView.addSubview(backgroundButton)
        
        backgroundButton.setTitle(nil, for: .normal)
        backgroundButton.addTarget(self, action: #selector(closeButtonTap), for: .touchUpInside)
        
        backgroundButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate(NSLayoutConstraint.fill(view: backgroundButton, in: containerView))
    }
    
    private func setupCloseButton() {
        containerView.addSubview(closeButton)
        
		closeButton.setImage(.Icons.cross, for: .normal)
		closeButton.tintColor = .Icons.iconAccentThemed
        closeButton.addTarget(self, action: #selector(closeButtonTap), for: .touchUpInside)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            closeButton.leadingAnchor.constraint(equalTo: contentStackView.trailingAnchor, constant: 8),
            closeButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -14),
            closeButton.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 14),
            closeButton.widthAnchor.constraint(equalToConstant: 18),
            closeButton.heightAnchor.constraint(equalTo: closeButton.widthAnchor)
        ])
    }
    
    private func setupContentLabels() {
        titleLabel.numberOfLines = 0
        contentStackView.addArrangedSubview(titleLabel)
        
        descriptionLabel.numberOfLines = 0
        contentStackView.addArrangedSubview(descriptionLabel)
    }
    
    // MARK: Actions
    @objc func closeButtonTap(_ sender: Any) {
        dismiss()
    }
        
    func set(
        appearance: Appearance = .standard,
        title: String,
        description: String? = nil,
        hasCloseButton: Bool,
        iconImage: UIImage?,
        titleFont: UIFont,
        startBannerOffset: CGFloat
    ) {
        self.appearance = appearance
        self.titleLabel.text = title
        self.descriptionLabel.text = description
        self.startBannerOffset = startBannerOffset
        
        updateUI(
            hasCloseButton: hasCloseButton,
            iconImage: iconImage,
            titleFont: titleFont
        )
    }
    
    private var appearance: Appearance = .standard
    
    // MARK: Appearance
    struct Appearance {
        let backgroundColor: UIColor
        let iconColor: UIColor
        let closeIconColor: UIColor
        let titleStyle: Style.Label.ColoredLabel
        let descriptionStyle: Style.Label.ColoredLabel
                
        static let accent: Appearance = Appearance(
            backgroundColor: Style.Color.Palette.red,
            iconColor: Style.Color.Palette.white,
            closeIconColor: Style.Color.Palette.white,
            titleStyle: Style.Label.contrastHeadline3,
            descriptionStyle: Style.Label.contrastSubhead
        )
        static let standard: Appearance = Appearance(
			backgroundColor: .Background.backgroundModal,
			iconColor: .Icons.iconAccent,
			closeIconColor: .Icons.iconAccentThemed,
            titleStyle: Style.Label.primaryHeadline3,
            descriptionStyle: Style.Label.secondarySubhead
        )
    }
    
    private func updateUI(
        hasCloseButton: Bool,
        iconImage: UIImage?,
        titleFont: UIFont
    ) {
        containerView.backgroundColor = appearance.backgroundColor
		
        closeButton.tintColor = appearance.closeIconColor
        
        titleLabel <~ appearance.titleStyle
        descriptionLabel <~ appearance.descriptionStyle
        
		iconImageView.contentMode = .scaleAspectFit
		iconImageView.image = iconImage?.tintedImage(withColor: self.appearance.iconColor)
        closeButton.isHidden = !hasCloseButton
		iconImageView.tintColor = .Icons.iconAccent

        titleLabel.font = titleFont
        guard let text = descriptionLabel.text
        else {
            descriptionLabel.isHidden = true
            return
        }
        
        descriptionLabel.isHidden = text.isEmpty
    }
    
    private func invalidateTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    @objc private func handleDrag(_ recognizer: UIPanGestureRecognizer) {
        let velocity = recognizer.velocity(in: superview)
        
        if velocity.y < 0 && !animationIsStarted {
            invalidateTimer()
            dismiss()
        }
    }
    
    func setupTimer(){
        invalidateTimer()
        timer = Timer.scheduledTimer(
            withTimeInterval: 3.5,
            repeats: false,
            block: { [weak self] _ in
                self?.dismiss()
            }
        )
    }
    
    @objc private func dismiss() {
        animationIsStarted = true
        
        UIView.animate(
            withDuration: Constants.duration,
            delay: 0,
            options: .curveEaseInOut,
            animations: {
                self.transform = CGAffineTransform(
                    translationX: 0,
                    y: (self.startBannerOffset ?? Constants.defaultStartBannerOffset) - self.frame.height
                )
            },
            completion: { _ in
                self.animationIsStarted = false
                self.removeFromSuperview()
            }
        )
    }
	
	// MARK: - Dark theme support
	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
		
		guard let image = iconImageView.image
		else { return }
		
		let tintedColor: UIColor = self.appearance.iconColor
		
		iconImageView.image = image.tintedImage(withColor: tintedColor)
	}
}
