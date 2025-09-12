//
//  BonusCell.swift
//  AlfaStrah
//
//  Created by vit on 21.06.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

import UIKit
import Legacy
import Lottie
import SDWebImage

class BonusCell: UITableViewCell {
	static let id: Reusable<BonusCell> = .fromClass()
	
	private let containerView = UIView()
	private let titleLabel = UILabel()
	private let pointsLabel = UILabel()
	private let pointsIconView = UIImageView()
	private let bonusImageView = UIImageView()
	private let descriptionLabel = UILabel()
	private let actionButton = RoundEdgeButton()
	private let horizontalPointsStackView = UIStackView()
	
	private var action: (() -> Void)?
	
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)

		setupUI()
	}

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)

		setupUI()
	}
	
	private func setupUI() {
		clearStyle()
		
		selectionStyle = .none
		
		setupContainerView()
		
		containerView.addSubview(actionButton)
		actionButton.height(35)
		actionButton.edgesToSuperview(excluding: .top, insets: insets(16))

		let stackView = UIStackView()
		stackView.axis = .vertical
		stackView.distribution = .fill
		stackView.alignment = .fill
		stackView.spacing = 0
		
		containerView.addSubview(stackView)
		stackView.topToSuperview(offset: 16)
		stackView.leadingToSuperview(offset: 16)
		stackView.bottomToTop(of: actionButton, offset: -10, relation: .equalOrLess)
		
		containerView.addSubview(bonusImageView)
		bonusImageView.height(120)
		bonusImageView.widthToHeight(of: bonusImageView)
		bonusImageView.topToSuperview(offset: 12)
		bonusImageView.trailingToSuperview(offset: 12)
		bonusImageView.leadingToTrailing(of: stackView)
		bonusImageView.bottomToTop(of: actionButton, offset: -7, relation: .equalOrLess)
		
		titleLabel.numberOfLines = 0
		titleLabel <~ Style.Label.primaryTitle2
		stackView.addArrangedSubview(titleLabel)
		
		horizontalPointsStackView.axis = .horizontal
		horizontalPointsStackView.distribution = .fill
		horizontalPointsStackView.alignment = .leading
		horizontalPointsStackView.spacing = 4
		horizontalPointsStackView.layoutMargins = UIEdgeInsets(top: 4, left: 0, bottom: 0, right: 0)
		
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
		descriptionLabel <~ Style.Label.primarySubhead
		stackView.addArrangedSubview(descriptionLabel)
		
		actionButton <~ Style.RoundedButton.outlinedButtonSmall
	}
	
	// swiftlint:disable:next function_parameter_count
	func configure(
		imageUrl: URL?,
		title: String?,
		titleTextColor: UIColor?,
		description: String?,
		descriptionTextColor: UIColor?,
		amountText: String?,
		amountTextColor: UIColor?,
		amountIconUrl: URL?,
		buttonTitle: String?,
		buttonTitleTextColor: UIColor?,
		buttonBackgroundColor: UIColor?,
		buttonBorderColor: UIColor?,
		showActionButton: Bool,
		action: @escaping () -> Void
	) {
		bonusImageView.sd_setImage(with: imageUrl)
		
		titleLabel.text = title
		titleLabel.textColor = titleTextColor
		
		if let amountText {
			pointsIconView.sd_setImage(with: amountIconUrl)
			pointsLabel.text = amountText
			pointsLabel.textColor = amountTextColor
		} else {
			horizontalPointsStackView.removeFromSuperview()
		}
		
		descriptionLabel.text = description
		descriptionLabel.textColor = descriptionTextColor
		
		actionButton.isHidden = !showActionButton
		
		actionButton <~ Style.RoundedButton.RoundedParameterizedButton(
			textColor: buttonTitleTextColor ?? .Text.textAccent,
			backgroundColor: buttonBackgroundColor ?? .clear,
			borderColor: buttonBorderColor ?? .Stroke.strokeAccent
		)
		
		actionButton.setTitle(buttonTitle, for: .normal)
		actionButton.addTarget(self, action: #selector(actionButtonTap), for: .touchUpInside)
		
		self.action = action
	}
	
	private func setupContainerView() {
		containerView.backgroundColor = .Background.backgroundTertiary
		
		let cardView = containerView.embedded(hasShadow: true)
		
		contentView.addSubview(cardView)
		
		cardView.translatesAutoresizingMaskIntoConstraints = false
		
		cardView.edgesToSuperview(insets: UIEdgeInsets(top: 6, left: 18, bottom: 6, right: 18))
	}
	
	override func prepareForReuse() {
		super.prepareForReuse()
		
		bonusImageView.sd_cancelCurrentImageLoad()
		pointsIconView.sd_cancelCurrentImageLoad()
	}
	
	@objc private func actionButtonTap() {
		action?()
	}
}
