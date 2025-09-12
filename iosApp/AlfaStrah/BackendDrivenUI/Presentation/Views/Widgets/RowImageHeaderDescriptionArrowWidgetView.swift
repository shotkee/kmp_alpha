//
//  RowImageHeaderDescriptionArrowWidgetView.swift
//  AlfaStrah
//
//  Created by vit on 25.10.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

extension BDUI {
	class RowImageHeaderDescriptionArrowWidgetView: WidgetView<RowImageHeaderDescriptionArrowWidgetDTO> {
		private let containerView = UIView()
		private let titleLabel = UILabel()
		private let amountLabel = UILabel()
		private let iconImageView = UIImageView()
		private let backgroundImageView = UIImageView()
		private let descriptionLabel = UILabel()
		private let arrowAccessoryImageView = UIImageView()
		
		private let horizontalStackView = UIStackView()
		private let cardView = CardView()
		private let widgetSelectorContainer = UIView()
		
		required init(
			block: RowImageHeaderDescriptionArrowWidgetDTO,
			horizontalInset: CGFloat = 18,
			handleEvent: @escaping (EventsDTO) -> Void
		) {
			super.init(block: block, horizontalInset: horizontalInset, handleEvent: handleEvent)
			
			setupUI()
			setupTapGestureRecognizer()
		}
		
		required init?(coder aDecoder: NSCoder) {
			fatalError("init(coder:) has not been implemented")
		}
		
		private func setupTapGestureRecognizer() {
			let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(viewTap))
			addGestureRecognizer(tapGestureRecognizer)
		}
		
		private func setupContainerView() {
			containerView.backgroundColor = .Background.backgroundTertiary
			
			addSubview(cardView)
			cardView.edgesToSuperview(insets: UIEdgeInsets(top: 0, left: self.horizontalInset, bottom: 0, right: self.horizontalInset))
			
			cardView.cornerRadius = 16
			cardView.hideShadow = false
			cardView.set(content: containerView)
		}
		
		private func setupUI() {
			self.layer.masksToBounds = false
			self.clipsToBounds = false
			
			setupContainerView()
			
			let stackView = UIStackView()
			stackView.axis = .vertical
			stackView.distribution = .fill
			stackView.alignment = .fill
			stackView.spacing = 0
			
			containerView.addSubview(stackView)
			stackView.topToSuperview(offset: 16)
			stackView.leadingToSuperview(offset: 16)
			stackView.bottomToSuperview(offset: -16, relation: .equalOrLess)
			
			containerView.addSubview(arrowAccessoryImageView)
			arrowAccessoryImageView.topToSuperview(offset: 16)
			arrowAccessoryImageView.height(24)
			arrowAccessoryImageView.widthToHeight(of: arrowAccessoryImageView)
			arrowAccessoryImageView.trailingToSuperview(offset: 16)
			
			containerView.addSubview(backgroundImageView)
			backgroundImageView.height(82)
			backgroundImageView.width(100)
			backgroundImageView.topToBottom(of: arrowAccessoryImageView, offset: 18, relation: .equalOrGreater)
			backgroundImageView.trailingToSuperview(offset: 12)
			backgroundImageView.leadingToTrailing(of: stackView)
			backgroundImageView.bottomToSuperview()
			
			titleLabel.numberOfLines = 0
			titleLabel <~ Style.Label.primaryHeadline1
			titleLabel.text = block.title?.text
			stackView.addArrangedSubview(titleLabel)
			
			horizontalStackView.axis = .horizontal
			horizontalStackView.distribution = .fill
			horizontalStackView.alignment = .leading
			horizontalStackView.spacing = 4
			horizontalStackView.layoutMargins = UIEdgeInsets(top: 4, left: 0, bottom: 0, right: 0)
			
			stackView.addArrangedSubview(horizontalStackView)
			
			amountLabel <~ Style.Label.primaryHeadline1
			amountLabel.text = block.amount?.text
			horizontalStackView.addArrangedSubview(amountLabel)
			
			iconImageView.width(18)
			iconImageView.height(18)
			iconImageView.contentMode = .scaleAspectFit
			horizontalStackView.addArrangedSubview(iconImageView)
			iconImageView.centerY(to: amountLabel.forFirstBaselineLayout)
			
			let spacerView = UIView()
			spacerView.setContentHuggingPriority(.defaultLow, for: .horizontal)
			horizontalStackView.addArrangedSubview(spacerView)
			
			stackView.addArrangedSubview(horizontalStackView)
			
			stackView.addArrangedSubview(spacer(10))
			
			descriptionLabel.numberOfLines = 0
			descriptionLabel <~ Style.Label.primarySubhead
			descriptionLabel.text = block.description?.text
			stackView.addArrangedSubview(descriptionLabel)
			
			updateTheme()
		}
		
		@objc private func viewTap() {
			if let events = block.events {
				handleEvent?(events)
			}
		}
		
		override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
			super.traitCollectionDidChange(previousTraitCollection)
			
			updateTheme()
		}
		
		private func updateTheme() {
			let currentUserInterfaceStyle = traitCollection.userInterfaceStyle
			
			cardView.contentColor = block.themedBackgroundColor?.color(for: currentUserInterfaceStyle) ?? .Background.backgroundTertiary
			
			backgroundImageView.sd_setImage(with: block.image?.url(for: currentUserInterfaceStyle))
			
			let color = block.arrow?.themedColor?.color(for: currentUserInterfaceStyle) ?? .Icons.iconSecondary
			
			arrowAccessoryImageView.image = .Icons.chevronSmallRight.resized(newWidth: 24)?.tintedImage(withColor: color)
			
			titleLabel.textColor = block.title?.themedColor?.color(for: currentUserInterfaceStyle)
			
			if block.amount?.text != nil {
				iconImageView.sd_setImage(with: block.icon?.url(for: currentUserInterfaceStyle))
				amountLabel.textColor = block.amount?.themedColor?.color(for: currentUserInterfaceStyle)
			} else {
				horizontalStackView.removeFromSuperview()
			}
			
			descriptionLabel.textColor = block.description?.themedColor?.color(for: currentUserInterfaceStyle)
		}
	}
}
