//
//  SquareLeftIconHeaderWidgetView.swift
//  AlfaStrah
//
//  Created by vit on 24.07.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

extension BDUI {
	class SquareLeftIconHeaderWidgetView: WidgetView<SquareLeftIconHeaderWidgetDTO> {
		private let cardView = CardView()
		private let contentStackView = UIStackView()
		private let iconImageView = UIImageView()
		private let descriptionLabel = UILabel()
		
		required init(
			block: SquareLeftIconHeaderWidgetDTO,
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
			contentStackView.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 20, right: 16)
			contentStackView.alignment = .leading
			contentStackView.distribution = .fill
			contentStackView.axis = .vertical
			contentStackView.spacing = 12
			contentStackView.backgroundColor = .clear
			
			iconImageView.height(32)
			iconImageView.width(32)
			contentStackView.addArrangedSubview(iconImageView)
			
			descriptionLabel <~ Style.Label.primaryText
			descriptionLabel.numberOfLines = 0
			descriptionLabel.text = block.themedTitle?.text
			contentStackView.addArrangedSubview(descriptionLabel)
			
			let spacer = UIView()
			spacer.setContentHuggingPriority(.defaultLow, for: .vertical)
			contentStackView.addArrangedSubview(spacer)
			
			addSubview(cardView)
			
			cardView.edgesToSuperview()
			cardView.cornerRadius = 16
			cardView.set(content: contentStackView)
			
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
			
			contentStackView.backgroundColor = block.themedBackgroundColor?.color(for: currentUserInterfaceStyle) ?? .Background.backgroundTertiary
			cardView.contentColor = block.themedBackgroundColor?.color(for: currentUserInterfaceStyle) ?? .Background.backgroundTertiary
			
			iconImageView.sd_setImage(with: block.themedLeftIcon?.url(for: currentUserInterfaceStyle))
			descriptionLabel.textColor = block.themedTitle?.themedColor?.color(for: currentUserInterfaceStyle) ?? .Text.textPrimary
		}
	}
}
