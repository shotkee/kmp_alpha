//
//  SquareIconHeaderCenterWidgetView.swift
//  AlfaStrah
//
//  Created by vit on 25.07.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

extension BDUI {
	class SquareIconHeaderCenterWidgetView: WidgetView<SquareIconHeaderCenterWidgetDTO> {
		private let cardView = CardView()
		private let contentStackView = UIStackView()
		private let iconImageView = UIImageView()
		private let descriptionLabel = UILabel()
		private let containerView = UIView()
		
		required init(
			block: SquareIconHeaderCenterWidgetDTO,
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
		
		private func setupUI() {
			contentStackView.isLayoutMarginsRelativeArrangement = true
			contentStackView.layoutMargins = .zero
			contentStackView.alignment = .center
			contentStackView.distribution = .fill
			contentStackView.axis = .vertical
			contentStackView.spacing = 12
			
			containerView.addSubview(contentStackView)
			contentStackView.center(in: containerView)
			
			iconImageView.height(24)
			iconImageView.width(24)
			contentStackView.addArrangedSubview(iconImageView)
			
			descriptionLabel <~ Style.Label.primaryText
			descriptionLabel.numberOfLines = 0
			descriptionLabel.text = block.themedTitle?.text
			contentStackView.addArrangedSubview(descriptionLabel)
			
			addSubview(cardView)
			cardView.edgesToSuperview()
			cardView.cornerRadius = 16
			cardView.set(content: containerView)
			cardView.hideShadow = true
			
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
			
			containerView.backgroundColor = block.themedBackgroundColor?.color(for: currentUserInterfaceStyle) ?? .Background.backgroundTertiary
			cardView.contentColor = block.themedBackgroundColor?.color(for: currentUserInterfaceStyle) ?? .Background.backgroundTertiary
			
			iconImageView.sd_setImage(with: block.themedIcon?.url(for: currentUserInterfaceStyle))
			descriptionLabel.textColor = block.themedTitle?.themedColor?.color(for: currentUserInterfaceStyle) ?? .Text.textPrimary
		}
	}
}
