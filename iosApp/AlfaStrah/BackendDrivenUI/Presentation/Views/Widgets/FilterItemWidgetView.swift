//
//  FilterItemWidgetView.swift
//  AlfaStrah
//
//  Created by vit on 17.07.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

extension BDUI {
	class FilterItemWidgetView: WidgetView<FilterItemWidgetDTO> {
		private let containerView = UIView()
		private let titleLabel = UILabel()
		private let underLineView = UIView()
		
		required init(
			block: FilterItemWidgetDTO,
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
			addSubview(containerView)
			
			containerView.edgesToSuperview()
			
			containerView.addSubview(titleLabel)
			
			titleLabel.edgesToSuperview(excluding: .bottom)
			titleLabel <~ Style.Label.primaryTitle2
			titleLabel.textAlignment = .center
			
			titleLabel.text = block.themedTitle?.text
			
			containerView.addSubview(underLineView)
			underLineView.height(3)
			underLineView.edgesToSuperview(excluding: .top)
			underLineView.topToBottom(of: titleLabel, offset: 5)
			
			underLineView.backgroundColor = .Background.backgroundAccent
			
			underLineView.isHidden = block.underlineThemedColor == nil
			
			updateTheme()
		}
		
		override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
			super.traitCollectionDidChange(previousTraitCollection)
			
			updateTheme()
		}
		
		private func updateTheme() {
			let currentInterfaceStyle = traitCollection.userInterfaceStyle
			
			containerView.backgroundColor = block.themedBackgroundColor?.color(for: currentInterfaceStyle)
			titleLabel.textColor = block.themedTitle?.themedColor?.color(for: currentInterfaceStyle)
			underLineView.backgroundColor = block.underlineThemedColor?.color(for: currentInterfaceStyle)
		}
	}
}
