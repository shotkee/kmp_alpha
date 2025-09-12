//
//  OneColumnLayoutView.swift
//  AlfaStrah
//
//  Created by vit on 24.04.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

extension BDUI {
	class OneColumnLayoutView: LayoutView<OneColumnLayoutDTO> {
		required init(
			block: OneColumnLayoutDTO,
			horizontalInset: CGFloat,
			handleEvent: @escaping (EventsDTO) -> Void
		) {
			super.init(block: block, horizontalInset: horizontalInset, handleEvent: handleEvent)
			
			setupUI()
		}
		
		private func setupUI() {
			let currentUserInterfaceStyle = traitCollection.userInterfaceStyle
			
			if let backgroundThemedColor = block.themedBackgroundColor {
				backgroundColor = backgroundThemedColor.color(for: currentUserInterfaceStyle)
			}
			
			let contentStackView = UIStackView(arrangedSubviews: widgets())
			addSubview(contentStackView)
			
			contentStackView.isLayoutMarginsRelativeArrangement = true
			contentStackView.layoutMargins = .zero
			contentStackView.alignment = .fill
			contentStackView.distribution = .fill
			contentStackView.axis = .vertical
			contentStackView.spacing = 0
			contentStackView.backgroundColor = .clear
			
			contentStackView.edgesToSuperview()
			contentStackView.width(to: self)
		}
		
		private func widgets() -> [UIView] {
			guard let content = block.content
			else { return [] }
			
			var views: [UIView] = []
			
			for widgetDto in content {
				views.append(ViewBuilder.constructWidgetView(
					for: widgetDto,
					horizontalLayoutOneSideContentInset: self.horizontalInset,
					handleEvent: { events in
						self.handleEvent?(events)
					}
				))
			}
			
			return views
		}
		
		required init?(coder: NSCoder) {
			fatalError("init(coder:) has not been implemented")
		}
		
		override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
			super.traitCollectionDidChange(previousTraitCollection)
			
			updateTheme()
		}
		
		private func updateTheme() {
			let currentUserInterfaceStyle = traitCollection.userInterfaceStyle
			
			if let backgroundThemedColor = block.themedBackgroundColor {
				backgroundColor = backgroundThemedColor.color(for: currentUserInterfaceStyle)
			}
		}
	}
}
