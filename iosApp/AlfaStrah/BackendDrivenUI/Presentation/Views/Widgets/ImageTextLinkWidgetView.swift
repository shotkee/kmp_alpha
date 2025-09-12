//
//  ImageTextLinkWidgetView.swift
//  AlfaStrah
//
//  Created by vit on 25.07.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

import SDWebImage

extension BDUI {
	class ImageTextLinkWidgetView: WidgetView<ImageTextLinkWidgetDTO> {
		private let containerView = UIView()
		private let contentStackView = UIStackView()
		private let imageView = UIImageView()
		
		private let titleLabel = UILabel()
		private let descriptionLabel = UILabel()
		private let linkButton = UIButton(type: .system)
		private let linkButtonTitle = UILabel()
		
		required override init(
			block: ImageTextLinkWidgetDTO,
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
			addSubview(containerView)
			containerView.edgesToSuperview(insets: UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16))
			
			contentStackView.isLayoutMarginsRelativeArrangement = true
			contentStackView.layoutMargins = .zero
			contentStackView.alignment = .fill
			contentStackView.distribution = .fill
			contentStackView.axis = .vertical
			contentStackView.spacing = 0
			
			contentStackView.addArrangedSubview(titleLabel)
			titleLabel.numberOfLines = 0
			titleLabel <~ Style.Label.primaryHeadline1
			titleLabel.text = block.themedTitle?.text
			
			contentStackView.addArrangedSubview(spacer(8))
			
			contentStackView.addArrangedSubview(descriptionLabel)
			descriptionLabel.numberOfLines = 0
			descriptionLabel <~ Style.Label.primaryText
			descriptionLabel.text = block.themedDescription?.text
			
			contentStackView.addArrangedSubview(spacer(12))
			
			contentStackView.addArrangedSubview(linkButton)
			linkButton.addSubview(linkButtonTitle)
			
			linkButton.addTarget(self, action: #selector(linkButtonTap), for: .touchUpInside)
			
			linkButtonTitle.edgesToSuperview()
			linkButtonTitle <~ Style.Label.accentButtonSmall
			
			linkButtonTitle.text = block.button?.themedText?.text
			
			containerView.addSubview(imageView)
			imageView.height(80)
			imageView.width(80)
			imageView.leftToSuperview()
			imageView.topToSuperview(offset: 24)
			imageView.bottomToSuperview(offset: -24, relation: .equalOrLess)
			
			containerView.addSubview(contentStackView)
			contentStackView.topToSuperview(offset: 24)
			contentStackView.leadingToTrailing(of: imageView, offset: 20)
			contentStackView.bottomToSuperview(offset: -24, relation: .equalOrLess)
			contentStackView.trailingToSuperview()
			
			updateTheme()
		}
		
		@objc private func viewTap() {
			if let events = block.events {
				handleEvent?(events)
			}
		}
		
		@objc private func linkButtonTap() {
			if let events = block.button?.events {
				handleEvent?(events)
			}
		}
		
		override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
			super.traitCollectionDidChange(previousTraitCollection)
			
			updateTheme()
		}
		
		private func updateTheme() {
			let currentUserInterfaceStyle = traitCollection.userInterfaceStyle
			
			containerView.backgroundColor = block.themedBackgroundColor?.color(for: currentUserInterfaceStyle) ?? .clear
			
			imageView.sd_setImage(with: block.themedImage?.url(for: currentUserInterfaceStyle))
			
			titleLabel.textColor = block.themedTitle?.themedColor?.color(for: currentUserInterfaceStyle) ?? .Text.textPrimary
			descriptionLabel.textColor = block.themedDescription?.themedColor?.color(for: currentUserInterfaceStyle) ?? .Text.textPrimary
			
			linkButtonTitle.textColor = block.button?.themedText?.themedColor?.color(for: currentUserInterfaceStyle) ?? .Text.textAccent
		}
	}
}
