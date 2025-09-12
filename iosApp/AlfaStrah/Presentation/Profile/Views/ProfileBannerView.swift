//
//  ProfileBannerView.swift
//  AlfaStrah
//
//  Created by mac on 16.03.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//
import UIKit
import TinyConstraints
import SDWebImage

class ProfileBannerView: UIView {
	private let containerView = UIView()
	private let titleLabel = UILabel()
	private let pointsLabel = UILabel()
	private let pointsIconView = UIImageView()
	private let bonusImageView = UIImageView()
	private let descriptionLabel = UILabel()
	private let linkLabel = UILabel()
	
	private let stackView = UIStackView()
	private let horizontalPointsStackView = UIStackView()
	
	private var openURL: (() -> Void)?
	
	override init(frame: CGRect) {
		super.init(frame: frame)

		setupUI()
	}
	
	func set(
		themedTitle: ThemedText?,
		themedDescription: ThemedText?,
		themedBackgroundColor: ThemedValue?,
		themedImage: ThemedValue?,
		themedLink: ThemedLink?,
		amountThemedText: ThemedText?,
		amountThemedIcon: ThemedValue?,
		openURL: @escaping () -> Void
	) {
		self.openURL = openURL
		self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openlink)))
		
		let currentUserInterfaceStyle = traitCollection.userInterfaceStyle
		
		if let themedTitle {
			titleLabel.text = themedTitle.text
			titleLabel.textColor = themedTitle.themedColor?.color(for: currentUserInterfaceStyle)
		} else {
			stackView.removeArrangedSubview(titleLabel)
		}
		
		if let themedDescription {
			descriptionLabel.text = themedDescription.text
			descriptionLabel.textColor = themedDescription.themedColor?.color(for: currentUserInterfaceStyle)
		} else {
			stackView.removeArrangedSubview(descriptionLabel)
		}
		
		if let themedLink {
			linkLabel.text = themedLink.themedText?.text
			linkLabel.textColor = themedLink.themedText?.themedColor?.color(for: currentUserInterfaceStyle)
		} else {
			stackView.removeArrangedSubview(linkLabel)
		}
		
		if let amountThemedText {
			pointsLabel.text = amountThemedText.text
			pointsLabel.textColor = amountThemedText.themedColor?.color(for: currentUserInterfaceStyle)
			pointsIconView.sd_setImage(with: amountThemedIcon?.url(for: currentUserInterfaceStyle))
		} else {
			stackView.removeArrangedSubview(horizontalPointsStackView)
		}
	
		bonusImageView.sd_setImage(with: themedImage?.url(for: currentUserInterfaceStyle))
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	@objc private func openlink() {
		openURL?()
	}

	private func setupUI() {
		setupContainerView()
		
		containerView.addSubview(linkLabel)

		stackView.axis = .vertical
		stackView.distribution = .fill
		stackView.alignment = .fill
		stackView.spacing = 0
		
		containerView.addSubview(stackView)
		stackView.topToSuperview(offset: 16)
		stackView.leadingToSuperview(offset: 16)
		stackView.bottomToTop(of: linkLabel, offset: -10)
		
		containerView.addSubview(bonusImageView)
		bonusImageView.height(120)
		bonusImageView.widthToHeight(of: bonusImageView)
		bonusImageView.topToSuperview(offset: 12, relation: .equalOrGreater)
		bonusImageView.trailingToSuperview(offset: 12)
		bonusImageView.leadingToTrailing(of: stackView, offset: 8)
		bonusImageView.bottomToSuperview(offset: -12)
		
		titleLabel.numberOfLines = 0
		titleLabel <~ Style.Label.primaryTitle2
		stackView.addArrangedSubview(titleLabel)
		
		stackView.addArrangedSubview(spacer(4))
		
		horizontalPointsStackView.axis = .horizontal
		horizontalPointsStackView.distribution = .fill
		horizontalPointsStackView.alignment = .leading
		horizontalPointsStackView.spacing = 4
		
		stackView.addArrangedSubview(horizontalPointsStackView)
		
		pointsLabel <~ Style.Label.primaryTitle2
		horizontalPointsStackView.addArrangedSubview(pointsLabel)

		pointsIconView.width(18)
		pointsIconView.height(24)
		pointsIconView.contentMode = .scaleAspectFit
		horizontalPointsStackView.addArrangedSubview(pointsIconView)
		
		let spacerView = UIView()
		spacerView.setContentHuggingPriority(.defaultLow, for: .horizontal)
		horizontalPointsStackView.addArrangedSubview(spacerView)
		
		stackView.addArrangedSubview(horizontalPointsStackView)
		
		stackView.addArrangedSubview(spacer(10))
		
		descriptionLabel.numberOfLines = 0
		descriptionLabel <~ Style.Label.secondarySubhead
		stackView.addArrangedSubview(descriptionLabel)
		
		linkLabel <~ Style.Label.accentButtonSmall
		linkLabel.leadingToSuperview(offset: 16)
		linkLabel.bottomToSuperview(offset: -16)
		linkLabel.trailingToLeading(of: bonusImageView, offset: -8)
	}
	
	private func setupContainerView() {
		containerView.backgroundColor = .Background.fieldBackground
		
		let cardView = containerView.embedded(hasShadow: true)
		
		self.addSubview(cardView)
		
		cardView.translatesAutoresizingMaskIntoConstraints = false
		
		cardView.edgesToSuperview()
	}
}
