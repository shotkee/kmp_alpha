//
//  RowIconDescriptionWidgetView.swift
//  AlfaStrah
//
//  Created by vit on 16.07.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

extension BDUI {
	class RowIconDescriptionWidgetView: WidgetView<RowIconDescriptionWidgetDTO> {
		private let containerView = UIView()
		private let cardView = CardView()
		private let titleLabel = UILabel()
		private let textLabel = UILabel()
		private let iconImageView = UIImageView()
		private let accessoryImageView = UIImageView()
		private let textStackView = UIStackView()
		
		required init(
			block: RowIconDescriptionWidgetDTO,
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
			containerView.addSubview(iconImageView)
			iconImageView.width(30)
			iconImageView.heightToWidth(of: iconImageView)
			iconImageView.contentMode = .scaleAspectFit
			iconImageView.topToSuperview(offset: 20, relation: .equalOrGreater)
			iconImageView.leadingToSuperview(offset: 16)
			iconImageView.bottomToSuperview(offset: -20, relation: .equalOrLess)
			iconImageView.centerYToSuperview()
			
			containerView.addSubview(textStackView)
			textStackView.topToSuperview(offset: 20, relation: .equalOrGreater)
			textStackView.leadingToTrailing(of: iconImageView, offset: 10)
			textStackView.bottomToSuperview(offset: -20, relation: .equalOrLess)
			textStackView.centerYToSuperview()
			
			containerView.addSubview(accessoryImageView)
			accessoryImageView.contentMode = .scaleAspectFit
			accessoryImageView.height(20)
			accessoryImageView.widthToHeight(of: accessoryImageView)
			accessoryImageView.topToSuperview(offset: 20, relation: .equalOrGreater)
			accessoryImageView.bottomToSuperview(offset: -16, relation: .equalOrLess)
			accessoryImageView.leadingToTrailing(of: textStackView)
			accessoryImageView.trailingToSuperview(offset: 20)
			accessoryImageView.centerYToSuperview()
			
			textStackView.isLayoutMarginsRelativeArrangement = true
			textStackView.layoutMargins = .zero
			textStackView.alignment = .fill
			textStackView.distribution = .fill
			textStackView.axis = .vertical
			textStackView.spacing = 0
			textStackView.backgroundColor = .clear
			
			cardView.set(content: containerView)
			cardView.cornerRadius = 24
			
			addSubview(cardView)
			cardView.leadingToSuperview(offset: horizontalInset)
			cardView.topToSuperview()
			cardView.trailingToSuperview(offset: horizontalInset)
			cardView.bottomToSuperview()
			
			updateTheme()
		}
		
		override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
			super.traitCollectionDidChange(previousTraitCollection)
			
			updateTheme()
		}
		
		private func updateTheme() {
			let currentUserInterfaceStyle = traitCollection.userInterfaceStyle
			
			let backgroundColor = block.themedBackgroundColor?.color(
				for: currentUserInterfaceStyle
			) ?? .Background.backgroundSecondary
			
			cardView.contentColor = backgroundColor
			containerView.backgroundColor = backgroundColor
			
			textStackView.arrangedSubviews.forEach {
				$0.removeFromSuperview()
			}
			
			if let themedIcon = block.themedIcon {
				iconImageView.sd_setImage(with: themedIcon.url(for: currentUserInterfaceStyle))
			}
			
			if let title = block.themedTitle {
				titleLabel.text = title.text
				
				titleLabel <~ Style.Label.contrastSubhead
				titleLabel.numberOfLines = 0
				
				titleLabel.textColor = title.themedColor?.color(for: currentUserInterfaceStyle)
				
				textStackView.addArrangedSubview(titleLabel)
			}
			
			if let description = block.themedDescription {
				textLabel.text = description.text
				
				textLabel <~ Style.Label.contrastText
				textLabel.numberOfLines = 0
				
				textLabel.textColor = description.themedColor?.color(for: currentUserInterfaceStyle)
				
				textStackView.addArrangedSubview(textLabel)
			}
			
			if let arrow = block.arrow {
				accessoryImageView.image = .Icons.chevronSmallRight
					.resized(newWidth: 20)?
					.tintedImage(
						withColor: arrow.themedColor?.color(for: currentUserInterfaceStyle) ?? .Icons.iconContrast
					)
			}
		}
	}
}
