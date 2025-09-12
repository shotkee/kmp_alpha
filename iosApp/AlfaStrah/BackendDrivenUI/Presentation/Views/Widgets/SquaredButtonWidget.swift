//
//  SquaredButtonWidget.swift
//  AlfaStrah
//
//  Created by vit on 22.07.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

extension BDUI {
	class SquaredButtonWidget: WidgetView<SquaredButtonWidgetDTO> {
		private let buttonContainer = UIButton(type: .system)
		private let accessoryArrowImageView = UIImageView()
		private let iconImageView = UIImageView()
		private let buttonTitleLabel = UILabel()
		
		required init(
			block: SquaredButtonWidgetDTO,
			horizontalInset: CGFloat = 18,
			handleEvent: @escaping (EventsDTO) -> Void
		) {
			super.init(block: block, horizontalInset: horizontalInset, handleEvent: handleEvent)
			
			setupUI()
		}
		
		required init?(coder aDecoder: NSCoder) {
			fatalError("init(coder:) has not been implemented")
		}
		
		private func setupUI() {
			buttonContainer.layer.cornerRadius = 12
			buttonContainer.layer.masksToBounds = true
			
			buttonContainer.addSubview(iconImageView)
			iconImageView.height(24)
			iconImageView.width(24)
			iconImageView.leadingToSuperview(offset: 12)
			iconImageView.centerYToSuperview()
			
			buttonTitleLabel.textAlignment = .left
			buttonTitleLabel.numberOfLines = 0
			buttonTitleLabel <~ Style.Label.primaryButtonLarge
			buttonTitleLabel.text = block.themedTitle?.text
			
			buttonContainer.addSubview(buttonTitleLabel)
			
			buttonTitleLabel.leadingToTrailing(of: iconImageView, offset: 8)
			buttonTitleLabel.topToSuperview(offset: 17)
			buttonTitleLabel.bottomToSuperview(offset: -17)
			
			buttonContainer.addSubview(accessoryArrowImageView)
			
			accessoryArrowImageView.leadingToTrailing(of: buttonTitleLabel, offset: 8, relation: .equalOrGreater)
			accessoryArrowImageView.trailingToSuperview(offset: 12)
			accessoryArrowImageView.centerYToSuperview()
			
			addSubview(buttonContainer)
			
			buttonContainer.edgesToSuperview()
			
			buttonContainer.addTarget(self, action: #selector(menuButtonTap), for: .touchUpInside)
		}
		
		@objc private func menuButtonTap() {
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
			
			buttonContainer.backgroundColor = block.themedBackgroundColor?.color(for: currentUserInterfaceStyle)
			
			let borderColor = block.themedBorderColor?.color(for: currentUserInterfaceStyle)?.cgColor
			buttonContainer.layer.borderColor = borderColor
			buttonContainer.layer.borderWidth = borderColor == nil ? 0 : 1
			
			let color = block.arrow?.themedColor?.color(for: currentUserInterfaceStyle) ?? .Icons.iconSecondary
			accessoryArrowImageView.image = .Icons.chevronSmallRight.resized(newWidth: 20)?.tintedImage(withColor: color)
			
			buttonTitleLabel.textColor = block.themedTitle?.themedColor?.color(for: currentUserInterfaceStyle) ?? .Text.textPrimary
			
			iconImageView.sd_setImage(with: block.themedIcon?.url(for: currentUserInterfaceStyle))
		}
	}
}
