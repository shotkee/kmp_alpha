//
//  ListWidgetView.swift
//  AlfaStrah
//
//  Created by vit on 09.09.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

extension BDUI {
	class ListWidgetView: WidgetView<ListWidgetDTO> {
		private let cardView = CardView()
		private let contentStackView = UIStackView()
		
		required init(
			block: ListWidgetDTO,
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
			contentStackView.layoutMargins = UIEdgeInsets(top: 18, left: 15, bottom: 18, right: 15)
			contentStackView.alignment = .leading
			contentStackView.distribution = .fill
			contentStackView.axis = .vertical
			contentStackView.spacing = 15
			contentStackView.backgroundColor = .clear
			
			addSubview(cardView)
			
			cardView.edgesToSuperview(insets: UIEdgeInsets(top: 0, left: self.horizontalInset, bottom: 0, right: self.horizontalInset))
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
			
			if let items = block.items {
				contentStackView.subviews.forEach { $0.removeFromSuperview() }
				
				items.forEach {
					contentStackView.addArrangedSubview(createItemView(themedText: $0.themedText, themedIcon: $0.themedIcon))
				}
			}
		}
		
		private func createItemView(
			themedText: ThemedTextComponentDTO?,
			themedIcon: ThemedValueComponentDTO?
		) -> UIStackView {
			let currentUserInterfaceStyle = traitCollection.userInterfaceStyle
			
			let stackView = UIStackView()
			stackView.axis = .horizontal
			stackView.distribution = .fill
			stackView.alignment = .top
			stackView.spacing = 9
			
			if let themedIcon {
				let iconImageView = UIImageView()
				
				iconImageView.height(16)
				iconImageView.widthToHeight(of: iconImageView)
				
				iconImageView.sd_setImage(with: themedIcon.url(for: currentUserInterfaceStyle))
				
				stackView.addArrangedSubview(iconImageView)
			}
			
			if let themedText {
				let textItem = UILabel()
				textItem <~ Style.Label.primaryText
				textItem.textAlignment = .left
				textItem.text = themedText.text
				textItem.textColor = themedText.themedColor?.color(for: currentUserInterfaceStyle)
				
				textItem.numberOfLines = 0
				
				textItem.setContentHuggingPriority(.required, for: .horizontal)
				
				stackView.addArrangedSubview(textItem)
			}
			
			return stackView
		}
	}
}
