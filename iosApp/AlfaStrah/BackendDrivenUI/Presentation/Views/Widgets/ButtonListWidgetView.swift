//
//  ButtonListWidgetView.swift
//  AlfaStrah
//
//  Created by vit on 25.10.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

extension BDUI {
	class ButtonListWidgetView: WidgetView<ButtonListWidgetDTO> {
		private let cardView = CardView()
		private let contentStackView = UIStackView()
		
		private var menuButtonActions: [(UIButton, EventsDTO?)] = []
		
		required init(
			block: ButtonListWidgetDTO,
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
			contentStackView.isLayoutMarginsRelativeArrangement = true
			contentStackView.layoutMargins = .zero
			contentStackView.alignment = .fill
			contentStackView.distribution = .fill
			contentStackView.axis = .vertical
			contentStackView.spacing = 0
			contentStackView.backgroundColor = .clear
			
			cardView.set(content: contentStackView)
			cardView.cornerRadius = 12
			
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
			
			let backgroundColor = block.themedBackgroundColor?.color(for: currentUserInterfaceStyle) ?? .Background.backgroundSecondary
			cardView.contentColor = backgroundColor
			contentStackView.backgroundColor = backgroundColor
			
			if let menuButtons = block.items {
				contentStackView.subviews.forEach({ $0.removeFromSuperview() })
				
				for (index, menuButton) in menuButtons.enumerated() {
					if index != 0 {
						contentStackView.addArrangedSubview(spacer(1, color: block.dividerColor?.color(for: currentUserInterfaceStyle) ?? .Stroke.divider))
					}
					
					let buttonContainer = UIButton(type: .system)
					
					let itemView = ButtonListItemView(block: menuButton)
					itemView.isUserInteractionEnabled = false
					
					buttonContainer.addSubview(itemView)
					itemView.edgesToSuperview()
					
					contentStackView.addArrangedSubview(buttonContainer)
					
					buttonContainer.addTarget(self, action: #selector(menuButtonTap), for: .touchUpInside)
					
					menuButtonActions.append((buttonContainer, menuButton.events))
				}
			}
		}
		
		@objc func menuButtonTap(_ sender: UIButton) {
			if let buttonEntry = menuButtonActions.first(where: { $0.0 === sender }),
			   let events = buttonEntry.1 {
				self.handleEvent?(events)
			}
		}
	}
	
	class ButtonListItemView: UIView {
		private let block: ButtonListItemComponentDTO
		
		private let containerView = UIView()
		private let titleLabel = UILabel()
		private let arrowImageView = UIImageView()
		private let logoImageView = UIImageView()
		
		required init(
			block: ButtonListItemComponentDTO
		) {
			self.block = block
			
			super.init(frame: .zero)
			
			setupUI()
		}
		
		required init?(coder: NSCoder) {
			fatalError("init(coder:) has not been implemented")
		}
		
		private func setupUI() {
			addSubview(containerView)
			
			containerView.edgesToSuperview(insets: insets(15))
			
			containerView.addSubview(titleLabel)
			titleLabel.text = block.title?.text
			titleLabel <~ Style.Label.primaryText
			
			containerView.addSubview(arrowImageView)
			arrowImageView.height(24)
			arrowImageView.widthToHeight(of: arrowImageView)
			
			containerView.addSubview(logoImageView)
			logoImageView.height(24)
			logoImageView.widthToHeight(of: logoImageView)
			
			logoImageView.topToSuperview(relation: .equalOrGreater)
			logoImageView.leadingToSuperview()
			logoImageView.bottomToSuperview(relation: .equalOrLess)
			
			titleLabel.topToSuperview(relation: .equalOrGreater)
			titleLabel.leadingToTrailing(of: logoImageView, offset: 6)
			titleLabel.bottomToSuperview(relation: .equalOrLess)
			
			arrowImageView.topToSuperview(relation: .equalOrGreater)
			arrowImageView.trailingToSuperview()
			arrowImageView.bottomToSuperview(relation: .equalOrLess)
			
			updateTheme()
		}
		
		override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
			super.traitCollectionDidChange(previousTraitCollection)
			
			updateTheme()
		}
		
		private func updateTheme() {
			let currentUserInterfaceStyle = traitCollection.userInterfaceStyle
			
			logoImageView.sd_setImage(with: block.icon?.url(for: currentUserInterfaceStyle))
			arrowImageView.image = .Icons.chevronSmallRight.tintedImage(
				withColor: block.arrow?.themedColor?.color(for: currentUserInterfaceStyle) ?? .Icons.iconSecondary
			)
			
			if let title = block.title {
				titleLabel <~ StyleExtension.Label(title, for: currentUserInterfaceStyle)
			}
		}
	}
}
