//
//  IconTitleDescriptionArrowWidgetView.swift
//  AlfaStrah
//
//  Created by vit on 15.11.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

extension BDUI {
	class IconTitleDescriptionArrowWidgetView: WidgetView<IconTitleDescriptionArrowWidgetDTO> {
		private let cardView = CardView()
		private let contentStackView = UIStackView()
		private let titleLabel = UILabel()
		private let descriptionLabel = UILabel()
		private let accessoryImageView = UIImageView()
		private let iconImageView = UIImageView()
		private let containerView = UIView()
		
		required init(
			block: IconTitleDescriptionArrowWidgetDTO,
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
		
		@objc private func viewTap() {
			if let events = block.events {
				handleEvent?(events)
			}
		}
		
		private func setupUI() {
			addSubview(cardView)
			cardView.edgesToSuperview(insets: UIEdgeInsets(top: 0, left: self.horizontalInset, bottom: 0, right: self.horizontalInset))
			
			cardView.cornerRadius = 19
			
			cardView.set(content: containerView)
			containerView.addSubview(contentStackView)
			
			contentStackView.topToSuperview()
			contentStackView.leadingToSuperview()
			contentStackView.bottomToSuperview()
			
			contentStackView.isLayoutMarginsRelativeArrangement = true
			contentStackView.layoutMargins = UIEdgeInsets(top: 20, left: 16, bottom: 20, right: 15)
			contentStackView.alignment = .leading
			contentStackView.distribution = .fill
			contentStackView.axis = .vertical
			contentStackView.spacing = 5
			contentStackView.backgroundColor = .clear
			
			if block.topIcon != nil {
				contentStackView.addArrangedSubview(iconImageView)
				iconImageView.height(20)
				iconImageView.widthToHeight(of: iconImageView)
			}
			
			if block.title != nil {
				contentStackView.addArrangedSubview(titleLabel)
				titleLabel.numberOfLines = 0
				titleLabel.textAlignment = .left
			}
			
			if block.description != nil {
				contentStackView.addArrangedSubview(descriptionLabel)
				descriptionLabel.numberOfLines = 0
				descriptionLabel.textAlignment = .left
			}
			
			containerView.addSubview(accessoryImageView)
			
			accessoryImageView.width(20)
			accessoryImageView.heightToWidth(of: accessoryImageView)
			accessoryImageView.topToSuperview(offset: 20)
			accessoryImageView.bottomToSuperview(offset: -20, relation: .equalOrLess)
			accessoryImageView.trailingToSuperview(offset: 16)
			accessoryImageView.leadingToTrailing(of: contentStackView)
			
			accessoryImageView.image = .Icons.chevronSmallRight
				.resized(newWidth: 20)?
				.tintedImage(withColor: .Icons.iconSecondary)
			
			let spacer = UIView()
			contentStackView.addArrangedSubview(spacer)
			spacer.setContentHuggingPriority(.defaultLow, for: .vertical)
			
			updateTheme()
		}
		
		override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
			super.traitCollectionDidChange(previousTraitCollection)
			
			updateTheme()
		}
		
		private func updateTheme() {
			let currentUserInterfaceStyle = traitCollection.userInterfaceStyle
			
			cardView.contentColor = block.themedBackgroundColor?.color(for: currentUserInterfaceStyle) ?? .Background.backgroundSecondary
			
			if let title = block.title {
				titleLabel <~ StyleExtension.MultiStyleLabel(title, for: currentUserInterfaceStyle)
			}
			
			if let description = block.description {
				descriptionLabel <~ StyleExtension.Label(description, for: currentUserInterfaceStyle)
			}
			
			if let accessoryImageThemedColor = block.arrow?.themedColor?.color(for: currentUserInterfaceStyle),
			   let accessoryImage = accessoryImageView.image {
				accessoryImageView.image = accessoryImage.tintedImage(withColor: accessoryImageThemedColor)
			}
			
			if let iconImageUrl = block.topIcon?.url(for: currentUserInterfaceStyle) {
				iconImageView.sd_setImage(with: iconImageUrl)
			}
		}
	}
}
