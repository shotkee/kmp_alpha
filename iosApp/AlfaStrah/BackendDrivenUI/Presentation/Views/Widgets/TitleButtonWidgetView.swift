//
//  TitleButtonWidgetView.swift
//  AlfaStrah
//
//  Created by vit on 25.10.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

import TinyConstraints

extension BDUI {
	class TitleButtonWidgetView: WidgetView<TitleButtonWidgetDTO> {
		private let cardView = CardView()
		private let containerView = UIView()
		private let titleLabel = UILabel()
		private let contentStackView = UIStackView()
		
		private lazy var contentStackViewTrailingConstraint: Constraint = {
			return contentStackView.trailingToSuperview(offset: 0)
		}()
		
		required override init(
			block: TitleButtonWidgetDTO,
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
			containerView.addSubview(contentStackView)
			
			contentStackView.isLayoutMarginsRelativeArrangement = true
			contentStackView.layoutMargins = insets(18)
			contentStackView.alignment = .center
			contentStackView.distribution = .fill
			contentStackView.axis = .horizontal
			contentStackView.spacing = 15
			contentStackView.backgroundColor = .clear
			
			contentStackView.edgesToSuperview()
			
			if let title = block.title {
				titleLabel.numberOfLines = 0
				titleLabel.text = title.text
				contentStackView.addArrangedSubview(titleLabel)
			}
			
			if let widgetDto = block.button {
				let widgetView = ViewBuilder.constructWidgetView(
					for: widgetDto,
					handleEvent: { events in
						self.handleEvent?(events)
					}
				)
				
				contentStackView.addArrangedSubview(widgetView)
				
				widgetView.height(35)
			}
			
			addSubview(cardView)
			
			cardView.edgesToSuperview(insets: UIEdgeInsets(top: 0, left: self.horizontalInset, bottom: 0, right: self.horizontalInset))
			cardView.cornerRadius = 12
			cardView.set(content: containerView)
			
			updateTheme()
		}
		
		override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
			super.traitCollectionDidChange(previousTraitCollection)
			
			updateTheme()
		}
		
		private func updateTheme() {
			let currentUserInterfaceStyle = traitCollection.userInterfaceStyle
			
			containerView.backgroundColor = block.themedBackgroundColor?.color(for: currentUserInterfaceStyle) ?? .Background.backgroundSecondary
			cardView.contentColor = block.themedBackgroundColor?.color(for: currentUserInterfaceStyle) ?? .Background.backgroundSecondary
			
			if let title = block.title {
				let color = title.themedColor?
					.color(for: currentUserInterfaceStyle) ?? .Text.textPrimary
				
				titleLabel <~ Style.Label.ColoredLabel(titleColor: color, font: Style.Font.text)
			}
		}
	}
}
