//
//  InformationWidgetView.swift
//  AlfaStrah
//
//  Created by vit on 23.04.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

extension BDUI {
	class InformationWidgetView: WidgetView<InformationWidgetDTO> {		
		private let titleLabel = UILabel()
		private let iconImageView = UIImageView()
		private let contentView = UIView()
		private let cardView = CardView()
		private let containerView = UIView()
		
		required init(
			block: InformationWidgetDTO,
			horizontalInset: CGFloat = 0,
			handleEvent: @escaping (EventsDTO) -> Void
		) {
			super.init(block: block, horizontalInset: horizontalInset, handleEvent: handleEvent)
			
			setupUI()
		}
		
		required init?(coder aDecoder: NSCoder) {
			fatalError("init(coder:) has not been implemented")
		}
		
		private func setupUI() {
			addSubview(containerView)
			containerView.edgesToSuperview()
			
			containerView.addSubview(cardView)
			
			cardView.cornerRadius = 16
			cardView.contentColor = .Background.backgroundTertiary
			cardView.set(content: contentView)
			
			cardView.topToSuperview()
			cardView.bottomToSuperview()
			cardView.leadingToSuperview(offset: self.horizontalInset)
			cardView.trailingToSuperview(offset: self.horizontalInset)
			
			cardView.cornerRadius = 16
			
			contentView.backgroundColor = .Background.backgroundTertiary
			
			titleLabel.numberOfLines = 0
			titleLabel <~ Style.Label.contrastSubhead
			
			contentView.addSubview(iconImageView)
			contentView.addSubview(titleLabel)
			
			iconImageView.width(18)
			iconImageView.height(18)
			
			iconImageView.leadingToSuperview(offset: 12)
			
			titleLabel.topToSuperview(offset: 12)
			titleLabel.bottomToSuperview(offset: -12)
			titleLabel.leadingToTrailing(of: iconImageView, offset: 4)
			
			titleLabel.trailingToSuperview(offset: 12)
			
			let offset = (titleLabel.font.ascender + titleLabel.font.descender) * 0.5
			iconImageView.centerY(to: titleLabel, titleLabel.firstBaselineAnchor, offset: -offset )
			
			if block.events != nil {
				setupTapGestureRecognizer()
			}
			
			titleLabel.text = block.title?.text
			
			updateTheme()
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
			
			let backgroundColor = block.themedBackgroundColor?
				.color(for: currentUserInterfaceStyle) ?? .Background.backgroundTertiary
			
			contentView.backgroundColor = backgroundColor
			cardView.contentColor = backgroundColor
			
			iconImageView.sd_setImage(with: block.themedIcon?.url(for: currentUserInterfaceStyle))
			
			let color = block.title?.themedColor?
				.color(for: currentUserInterfaceStyle) ?? .Text.textContrast
			
			titleLabel <~ Style.Label.ColoredLabel(titleColor: color, font: Style.Font.subhead)
		}
	}
}
