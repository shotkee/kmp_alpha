//
//  TwoColumnListWidgetView.swift
//  AlfaStrah
//
//  Created by vit on 29.10.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

extension BDUI {
	class TwoColumnListWidgetView: WidgetView<TwoColumnListWidgetDTO> {
		private let cardView = CardView()
		private let contentStackView = UIStackView()
		
		private var menuButtonActions: [(UIButton, EventsDTO?)] = []
		
		required override init(
			block: TwoColumnListWidgetDTO,
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
			contentStackView.layoutMargins = UIEdgeInsets(top: 0, left: self.horizontalInset, bottom: 0, right: self.horizontalInset)
			contentStackView.alignment = .fill
			contentStackView.distribution = .fill
			contentStackView.axis = .vertical
			contentStackView.spacing = 28
			contentStackView.backgroundColor = .clear
			
			addSubview(contentStackView)
			
			contentStackView.edgesToSuperview()
			
			updateTheme()
		}
		
		override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
			super.traitCollectionDidChange(previousTraitCollection)
			
			updateTheme()
		}
		
		private func updateTheme() {
			let currentUserInterfaceStyle = traitCollection.userInterfaceStyle
			
			let backgroundColor = block.themedBackgroundColor?.color(for: currentUserInterfaceStyle) ?? .clear
			cardView.contentColor = backgroundColor
			contentStackView.backgroundColor = backgroundColor
			
			if let items = block.items {
				contentStackView.subviews.forEach({ $0.removeFromSuperview() })
				
				items.forEach {
					contentStackView.addArrangedSubview(TwoColumnListWidgetItemView(block: $0))
				}
			}
		}
	}
}
