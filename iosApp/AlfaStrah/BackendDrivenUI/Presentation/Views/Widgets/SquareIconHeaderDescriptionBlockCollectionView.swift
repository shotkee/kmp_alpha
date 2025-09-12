//
//  SquareIconHeaderDescriptionBlockCollectionView.swift
//  AlfaStrah
//
//  Created by vit on 16.07.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

extension BDUI {
	class SquareIconHeaderDescriptionBlockCollectionView: WidgetView<SquareIconHeaderDescriptionWidgetDTO> {
		private let titleLabel = UILabel()
		private let descriptionLabel = UILabel()
		private let leftIconImageView = UIImageView()
		private let rightIconImageView = UIImageView()
		
		private let cardView = CardView()
		private let containerView = UIView()
		private let contentStackView = UIStackView()
		
		private let iconsContainerView = UIView()
		
		required init(
			block: SquareIconHeaderDescriptionWidgetDTO,
			horizontalInset: CGFloat = 0,
			handleEvent: @escaping (EventsDTO) -> Void
		) {
			super.init(block: block, horizontalInset: horizontalInset, handleEvent: handleEvent)
			
			setupUI()
		}
		
		override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
			super.traitCollectionDidChange(previousTraitCollection)
			
			updateTheme()
		}
		
		private func updateTheme() {
			let currentUserInterfaceStyle = traitCollection.userInterfaceStyle
			
			cardView.contentColor = block.themedBackgroundColor?.color(for: currentUserInterfaceStyle) ?? .Background.backgroundSecondary
			
			if let leftThemedIcon = block.leftThemedIcon {
				leftIconImageView.sd_setImage(with: leftThemedIcon.url(for: currentUserInterfaceStyle))
			}
			
			if let rightThemedIcon = block.rightThemedIcon {
				rightIconImageView.sd_setImage(with: rightThemedIcon.url(for: currentUserInterfaceStyle))
			}
			
			if let title = block.title {
				titleLabel.text = title.text
				
				let color = title.themedColor?
					.color(for: currentUserInterfaceStyle) ?? .Text.textPrimary
				
				titleLabel <~ Style.Label.ColoredLabel(titleColor: color, font: Style.Font.headline1)
			}
			
			if let description = block.description {
				descriptionLabel.text = description.text
				
				let color = description.themedColor?
					.color(for: currentUserInterfaceStyle) ?? .Text.textSecondary
				
				descriptionLabel <~ Style.Label.ColoredLabel(titleColor: color, font: Style.Font.text)
			}
		}
		
		private func setupUI() {
			addSubview(cardView)
			cardView.edgesToSuperview(
				insets: UIEdgeInsets(top: 0, left: self.horizontalInset, bottom: 0, right: self.horizontalInset)
			)
			
			cardView.cornerRadius = 16
			
			cardView.set(content: containerView)
			containerView.addSubview(contentStackView)
			contentStackView.edgesToSuperview(excluding: .bottom)
			contentStackView.bottomToSuperview(relation: .equalOrLess)
			
			contentStackView.isLayoutMarginsRelativeArrangement = true
			contentStackView.layoutMargins = insets(16)
			contentStackView.alignment = .fill
			contentStackView.distribution = .fill
			contentStackView.axis = .vertical
			contentStackView.spacing = 0
			contentStackView.backgroundColor = .clear
			
			if block.leftThemedIcon != nil || block.rightThemedIcon != nil {
				contentStackView.addArrangedSubview(iconsContainerView)
				iconsContainerView.addSubview(leftIconImageView)
				iconsContainerView.addSubview(rightIconImageView)
				iconsContainerView.height(to: leftIconImageView)
				contentStackView.addArrangedSubview(spacer(12))
				
				leftIconImageView.leadingToSuperview()
				leftIconImageView.topToSuperview(relation: .equalOrGreater)
				leftIconImageView.bottomToSuperview(relation: .equalOrLess)
				leftIconImageView.width(28)
				leftIconImageView.heightToWidth(of: leftIconImageView)
				
				rightIconImageView.trailingToSuperview()
				rightIconImageView.width(28)
				rightIconImageView.heightToWidth(of: leftIconImageView)
				rightIconImageView.topToSuperview(relation: .equalOrGreater)
				rightIconImageView.bottomToSuperview(relation: .equalOrLess)
				
				rightIconImageView.centerY(to: leftIconImageView)
				
				rightIconImageView.leadingToTrailing(of: leftIconImageView, offset: 8, relation: .equalOrGreater)
			}
			
			contentStackView.addArrangedSubview(titleLabel)
			titleLabel.numberOfLines = 0
			titleLabel.textAlignment = .left
			
			descriptionLabel.numberOfLines = 0
			descriptionLabel.textAlignment = .left
			
			if self.action != nil {
				setupTapGestureRecognizer()
			}
			
			self.set(block: block, layoutContentInset: horizontalInset)
			
			updateTheme()
		}
		
		private func set(
			block: SquareIconHeaderDescriptionWidgetDTO,
			layoutContentInset: CGFloat = 0
		) {
			if let description = block.description {
				contentStackView.addArrangedSubview(spacer(4))
				contentStackView.addArrangedSubview(descriptionLabel)
			}
		}
		
		private func setupTapGestureRecognizer() {
			let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(viewTap))
			addGestureRecognizer(tapGestureRecognizer)
		}
		
		@objc private func viewTap() {
			if let events = block.events {
				handleEvent?(events)
			}
		}
		
		required init?(coder aDecoder: NSCoder) {
			fatalError("init(coder:) has not been implemented")
		}
	}
}
