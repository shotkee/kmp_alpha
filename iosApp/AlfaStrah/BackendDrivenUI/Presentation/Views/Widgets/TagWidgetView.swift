//
//  TagWidgetView.swift
//  AlfaStrah
//
//  Created by vit on 14.11.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

extension BDUI {
	class TagWidgetView: WidgetView<TagWidgetDTO> {
		let label = UILabel()
		let iconImageView = UIImageView()
		let contentStackView = UIStackView()
		
		required init(
			block: TagWidgetDTO,
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
			contentStackView.layer.cornerRadius = 6
			contentStackView.layer.masksToBounds = true
			contentStackView.backgroundColor = .Background.backgroundTertiary
			
			contentStackView.isLayoutMarginsRelativeArrangement = true
			contentStackView.layoutMargins = UIEdgeInsets(top: 4, left: 6, bottom: 4, right: 8)
			contentStackView.alignment = .fill
			contentStackView.distribution = .fill
			contentStackView.axis = .horizontal
			contentStackView.spacing = 4
			contentStackView.backgroundColor = .clear
			
			label.lineBreakMode = .byTruncatingTail
			
			if block.icon != nil {
				contentStackView.addArrangedSubview(iconImageView)
				iconImageView.width(16)
				iconImageView.heightToWidth(of: iconImageView)
			}
			
			contentStackView.addArrangedSubview(label)
			
			updateTheme()
		}
		
		override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
			super.traitCollectionDidChange(previousTraitCollection)
			
			updateTheme()
		}
		
		private func updateTheme() {
			let currentUserInterfaceStyle = traitCollection.userInterfaceStyle
			
			contentStackView.backgroundColor = block.themedBackgroundColor?.color(for: currentUserInterfaceStyle) ?? .Background.backgroundTertiary
			
			if let icon = block.icon {
				iconImageView.sd_setImage(with: icon.url(for: currentUserInterfaceStyle))
			}
			
			if let title = block.title {
				label <~ StyleExtension.Label(title, for: currentUserInterfaceStyle)
			}
		}
	}
}
