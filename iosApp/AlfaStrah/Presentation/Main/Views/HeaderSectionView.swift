//
//  HeaderSectionView.swift
//  AlfaStrah
//
//  Created by vit on 07.04.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

import UIKit

class HeaderSectionView: UIView {
    private let containerView = UIView()
    private let rightWidgetButton = UIButton(type: .system)
    private let leftWidgetButton = UIButton(type: .system)
	private let badgesStackView = UIStackView()
    
    private let counterLabelContainerView = UIView()
    private let counterLabel = UILabel()
    
    var rightWidgetTap: (() -> Void)?
    var leftWidgetTap: (() -> Void)?
	
	private var leftWidgetThemedTitle: ThemedText?
	private var leftWidgetThemedIcons: [ThemedValue]?
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        setupUI()
    }

    private func setupUI() {
        addSubview(containerView)
		containerView.backgroundColor = .clear
		containerView.edgesToSuperview()
		
		setupLeftWidget()
		setupRightWidget()
    }
	
	private func setupRightWidget() {
		containerView.addSubview(rightWidgetButton)
		
		rightWidgetButton.trailingToSuperview(offset: 18)
		rightWidgetButton.topToSuperview(relation: .equalOrGreater)
		rightWidgetButton.bottomToSuperview(relation: .equalOrLess)
		rightWidgetButton.width(42)
		rightWidgetButton.heightToWidth(of: rightWidgetButton)
		rightWidgetButton.centerYToSuperview()
				
		rightWidgetButton.addSubview(counterLabelContainerView)
		counterLabelContainerView.addSubview(counterLabel)

		counterLabelContainerView.backgroundColor = .Pallete.accentRed
		counterLabelContainerView.layer.cornerRadius = 8
		counterLabelContainerView.layer.masksToBounds = true
	
		counterLabelContainerView.centerYToSuperview(offset: -6)
		counterLabelContainerView.leading(to: rightWidgetButton, rightWidgetButton.centerXAnchor)
		counterLabelContainerView.widthToHeight(of: counterLabelContainerView, relation: .equalOrGreater)
		
		counterLabel.edgesToSuperview(insets: UIEdgeInsets(top: 1, left: 3, bottom: 1, right: 3))
		
		counterLabel.translatesAutoresizingMaskIntoConstraints = false
		counterLabel <~ Style.Label.contrastCaption2
		counterLabel.textAlignment = .center
		counterLabel.numberOfLines = 1

		rightWidgetButton.backgroundColor = .Background.backgroundSecondary
		rightWidgetButton.layer.cornerRadius = 21
		rightWidgetButton.setTitle("", for: .normal)
		rightWidgetButton.addTarget(self, action: #selector(notificationsButtonTapHandler), for: .touchUpInside)
		rightWidgetButton.tintColor = .Icons.iconPrimary
		rightWidgetButton.setImage(.Icons.bell.resized(newWidth: 28), for: .normal)
	}
	
	private func setupLeftWidget() {
		containerView.addSubview(leftWidgetButton)
		leftWidgetButton.leadingToSuperview(offset: 18)
		leftWidgetButton.topToSuperview(relation: .equalOrGreater)
		leftWidgetButton.bottomToSuperview(relation: .equalOrLess)
		leftWidgetButton.centerYToSuperview()
				
		badgesStackView.isLayoutMarginsRelativeArrangement = true
		badgesStackView.axis = .horizontal
		badgesStackView.distribution = .fill
		badgesStackView.alignment = .fill
		badgesStackView.spacing = -7
		badgesStackView.isUserInteractionEnabled = false
		
		leftWidgetButton.addSubview(badgesStackView)
		badgesStackView.edgesToSuperview()

		leftWidgetButton.addTarget(self, action: #selector(leftWidgetButtonTap), for: .touchUpInside)
	}
    
    @objc private func notificationsButtonTapHandler() {
        rightWidgetTap?()
    }
    
    @objc private func leftWidgetButtonTap() {
		leftWidgetTap?()
    }
    
    func set(
		themedTitle: ThemedText?,
		themedIcons: [ThemedValue]?,
        counter: Int? = nil,
        showNotificationsButton: Bool = true,
        show: Bool = true,
		rightWidgetTap: (() -> Void)? = nil,
        leftWidgetTap: (() -> Void)? = nil
    ) {
        if let counter = counter {
            counterLabelContainerView.isHidden = counter == 0
            counterLabel.text = counter <= Constants.counterLimit
                ? String(counter)
                : "\(Constants.counterLimit)+"
        } else {
            counterLabelContainerView.isHidden = true
        }

        self.rightWidgetTap = rightWidgetTap
        self.leftWidgetTap = leftWidgetTap
        rightWidgetButton.isHidden = !showNotificationsButton
        self.isHidden = !show
				
		self.leftWidgetThemedIcons = themedIcons
		self.leftWidgetThemedTitle = themedTitle
		
		updateTheme()
    }

    struct Constants {
        static let counterLimit = 99
    }
    
    // MARK: - Dark Theme Support
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
		
		updateTheme()
    }
	
	private func updateTheme() {
		let currentUserInterfaceStyle = traitCollection.userInterfaceStyle
				
		badgesStackView.arrangedSubviews.forEach {
			$0.removeFromSuperview()
		}
		
		if let leftWidgetThemedIcons {
			for themedIcon in leftWidgetThemedIcons {
				let imageView = UIImageView()
				imageView.width(28)
				imageView.heightToWidth(of: imageView)
				imageView.layer.cornerRadius = 14
				imageView.layer.borderColor = UIColor.Background.background.cgColor
				imageView.layer.borderWidth = 2
				imageView.layer.masksToBounds = true
				
				imageView.sd_setImage(with: themedIcon.url(for: currentUserInterfaceStyle))
				imageView.backgroundColor = .clear
				
				badgesStackView.addArrangedSubview(imageView)
			}
		}
		
		if let leftWidgetThemedTitle {
			let horizontalSpacer = UIView()
			horizontalSpacer.width(18)
			badgesStackView.addArrangedSubview(horizontalSpacer)
			
			let titleLabel = UILabel()
			titleLabel.numberOfLines = 1
			titleLabel.text = leftWidgetThemedTitle.text
			titleLabel <~ Style.Label.accentHeadline1
			
			titleLabel.textColor = leftWidgetThemedTitle.themedColor?.color(for: currentUserInterfaceStyle)
			
			badgesStackView.addArrangedSubview(titleLabel)
		}
	}
}
