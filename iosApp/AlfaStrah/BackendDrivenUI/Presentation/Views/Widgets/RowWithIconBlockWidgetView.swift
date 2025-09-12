//
//  RowWithIconBlockWidgetView.swift
//  AlfaStrah
//
//  Created by vit on 15.04.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

extension BDUI {
	class RowWithIconBlockWidgetView: WidgetView<RowWithIconBlockWidgetDTO> {
		private let view = UIButton()
		private let containerView = UIView()
		private let iconImageView = UIImageView()
		private let accessoryImageView = UIImageView()
		private let titleLabelView = UILabel()
		
		required init(
			block: RowWithIconBlockWidgetDTO,
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
		
		private func setupUI() {
			let currentUserInterfaceStyle = traitCollection.userInterfaceStyle
			
			containerView.backgroundColor = block.themedBackgroundColor?.color(for: currentUserInterfaceStyle) ?? .Background.backgroundSecondary
			containerView.isUserInteractionEnabled = false
			view.addSubview(containerView)
			containerView.edgesToSuperview()
			
			containerView.addSubview(iconImageView)
			iconImageView.width(24)
			iconImageView.heightToWidth(of: iconImageView)
			iconImageView.sd_setImage(with: block.themedIcon?.url(for: currentUserInterfaceStyle))
			iconImageView.leadingToSuperview(offset: 16)
			iconImageView.topToSuperview(offset: 15, relation: .equalOrGreater)
			iconImageView.bottomToSuperview(offset: -15, relation: .equalOrLess)
			
			containerView.addSubview(titleLabelView)
			titleLabelView.numberOfLines = 0
			titleLabelView <~ Style.Label.primaryHeadline1
			
			titleLabelView.text = block.title?.text
			titleLabelView.textColor = block.title?.themedColor?.color(for: currentUserInterfaceStyle) ?? .Text.textPrimary
			
			titleLabelView.leadingToTrailing(of: iconImageView, offset: 8)
			titleLabelView.topToSuperview(offset: 16, relation: .equalOrGreater)
			titleLabelView.bottomToSuperview(offset: -16, relation: .equalOrLess)
			titleLabelView.centerYToSuperview()
			iconImageView.centerY(to: titleLabelView.forFirstBaselineLayout)
			
			if let accessoryImageThemedColor = block.accessoryImageThemedColor {
				containerView.addSubview(accessoryImageView)
				accessoryImageView.width(20)
				accessoryImageView.heightToWidth(of: accessoryImageView)
				
				let color = accessoryImageThemedColor.color(for: currentUserInterfaceStyle) ?? .Text.textSecondary
				accessoryImageView.image = .Icons.chevronSmallRight.resized(newWidth: 20)?.tintedImage(withColor: color)
				
				accessoryImageView.leadingToTrailing(of: titleLabelView)
				accessoryImageView.topToSuperview(offset: 17, relation: .equalOrGreater)
				accessoryImageView.bottomToSuperview(offset: -17, relation: .equalOrLess)
				accessoryImageView.trailingToSuperview(offset: 16)
				accessoryImageView.centerY(to: titleLabelView)
			} else {
				titleLabelView.trailingToSuperview(offset: 16)
			}
			
			let cardView = containerView.embedded(
				margins: UIEdgeInsets(top: 0, left: horizontalInset, bottom: 0, right: horizontalInset),
				hasShadow: true,
				cornerRadius: 16
			)
			
			addSubview(cardView)
			cardView.edgesToSuperview()
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
		
		override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
			super.traitCollectionDidChange(previousTraitCollection)
			
			updateTheme()
		}
		
		private func updateTheme() {
			let currentUserInterfaceStyle = traitCollection.userInterfaceStyle
			
			containerView.backgroundColor = block.themedBackgroundColor?.color(for: currentUserInterfaceStyle) ?? .Background.backgroundSecondary
			
			iconImageView.sd_setImage(with: block.themedIcon?.url(for: currentUserInterfaceStyle))
			
			titleLabelView.textColor = block.title?.themedColor?.color(for: currentUserInterfaceStyle) ?? .Text.textPrimary
			
			if let accessoryImageThemedColor = block.accessoryImageThemedColor {
				let color = accessoryImageThemedColor.color(for: currentUserInterfaceStyle) ?? .Text.textSecondary
				accessoryImageView.image = .Icons.chevronSmallRight.resized(newWidth: 20)?.tintedImage(withColor: color)
			}
		}
	}
}
