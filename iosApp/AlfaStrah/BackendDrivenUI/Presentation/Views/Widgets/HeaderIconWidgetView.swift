//
//  HeaderIconWidgetView.swift
//  AlfaStrah
//
//  Created by vit on 28.10.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

import SDWebImage

extension BDUI {
	class HeaderIconWidgetView: WidgetView<HeaderIconWidgetDTO> {
		private let contentStackView = UIStackView()
		private let leftTextLabel = UILabel()
		private let rightTextLabel = UILabel()
		private let iconImageView = UIImageView()
		
		required init(
			block: HeaderIconWidgetDTO,
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
			addSubview(contentStackView)
			contentStackView.edgesToSuperview()
			
			contentStackView.isLayoutMarginsRelativeArrangement = true
			contentStackView.layoutMargins = UIEdgeInsets(
				top: 0,
				left: horizontalInset,
				bottom: 0,
				right: horizontalInset
			)
			contentStackView.alignment = .leading
			contentStackView.distribution = .fill
			contentStackView.axis = .horizontal
			contentStackView.spacing = .zero
			contentStackView.backgroundColor = .clear
			
			leftTextLabel.numberOfLines = 1
			contentStackView.addArrangedSubview(leftTextLabel)
			
			contentStackView.addArrangedSubview(iconImageView)
			iconImageView.width(26)
			iconImageView.centerYToSuperview()
			iconImageView.heightToWidth(of: iconImageView)
			
			rightTextLabel.numberOfLines = 1
			contentStackView.addArrangedSubview(rightTextLabel)
			
			let spacerView = UIView()
			spacerView.setContentHuggingPriority(.defaultLow, for: .horizontal)
			contentStackView.addArrangedSubview(spacerView)
			
			updateTheme()
		}
		
		override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
			super.traitCollectionDidChange(previousTraitCollection)
			
			updateTheme()
		}
		
		private func updateTheme() {
			let currentUserInterfaceStyle = traitCollection.userInterfaceStyle
			
			contentStackView.backgroundColor = block.themedBackgroundColor?.color(for: currentUserInterfaceStyle) ?? .clear
			
			if let leftText = block.leftText {
				leftTextLabel <~ BDUI.StyleExtension.Label(leftText, for: currentUserInterfaceStyle)
			}
			
			if let rightText = block.rightText {
				rightTextLabel <~ BDUI.StyleExtension.Label(rightText, for: currentUserInterfaceStyle)
			}
			
			if let icon = block.icon {
				SDWebImageManager.shared.loadImage(
					with: icon.url(for: currentUserInterfaceStyle),
					options: .highPriority,
					progress: nil,
					completed: { image, _, _, _, _, _ in
						self.iconImageView.image = image?.resized(newWidth: 26, insets: insets(4))
					}
				)
			}
		}
	}
}
