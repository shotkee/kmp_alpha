//
//  HeaderWidgetView.swift
//  AlfaStrah
//
//  Created by vit on 15.04.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

import SDWebImage
extension BDUI {
	class HeaderWidgetView: WidgetView<HeaderWidgetDTO> {
		private let contentStackView = UIStackView()
		private let containerView = UIView()
		private let titleLabel = UILabel()
		private let actionButton = UIButton(type: .system)
		private let descriptionLabel = UILabel()
		private let actionButtonTitleLabel = UILabel()
		
		required override init(
			block: HeaderWidgetDTO,
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
			contentStackView.layoutMargins = UIEdgeInsets(
				top: 0,
				left: horizontalInset,
				bottom: 0,
				right: horizontalInset
			)
			contentStackView.alignment = .fill
			contentStackView.distribution = .fill
			contentStackView.axis = .vertical
			contentStackView.spacing = 2
			contentStackView.backgroundColor = .clear
			
			contentStackView.addArrangedSubview(containerView)
			
			titleLabel.numberOfLines = 0
			containerView.addSubview(titleLabel)
			titleLabel.leadingToSuperview()
			titleLabel.topToSuperview(relation: .equalOrGreater)
			titleLabel.bottomToSuperview(relation: .equalOrLess)
			
			containerView.addSubview(actionButton)
			
			setupActionButton()
			
			contentStackView.addArrangedSubview(descriptionLabel)
			
			addSubview(contentStackView)
			contentStackView.edgesToSuperview()
			
			updateTheme()
		}
		
		private func setupActionButton() {
			containerView.addSubview(actionButton)
			
			actionButton.trailingToSuperview()
			actionButton.leadingToTrailing(of: titleLabel, offset: 12, relation: .equalOrGreater)
			actionButton.topToSuperview(relation: .equalOrGreater)
			actionButton.bottomToSuperview(relation: .equalOrLess)
			
			actionButton.centerY(to: titleLabel.forFirstBaselineLayout)
			
			actionButton.addTarget(self, action: #selector(buttonTap), for: .touchUpInside)
			
			if let buttonThemedImage = block.button?.themedImage {
				actionButton.height(24)
				actionButton.widthToHeight(of: actionButton)
			} else if let rightButton = block.button?.themedSizedTitle {
				actionButton.addSubview(actionButtonTitleLabel)
				actionButtonTitleLabel <~ Style.Label.accentText
				
				actionButtonTitleLabel.numberOfLines = 1
				actionButtonTitleLabel.edgesToSuperview()
			}
		}
		
		@objc func buttonTap() {
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
			
			contentStackView.backgroundColor = block.themedBackgroundColor?.color(for: currentUserInterfaceStyle) ?? .clear
			
			if let title = block.title {
				titleLabel <~ StyleExtension.Label(title, for: currentUserInterfaceStyle)
			}
			
			if let description = block.description {
				descriptionLabel.numberOfLines = 0
				descriptionLabel.textAlignment = .left
				
				descriptionLabel <~ StyleExtension.Label(description, for: currentUserInterfaceStyle)
			}
			
			if let buttonThemedImage = block.button?.themedImage {
				SDWebImageManager.shared.loadImage(
					with: buttonThemedImage.url(for: currentUserInterfaceStyle),
					options: .highPriority,
					progress: nil,
					completed: { image, _, _, _, _, _ in
						self.actionButton.setImage(image?.resized(newWidth: 24), for: .normal)
					}
				)
			}
			
			if let buttonThemedTitle = block.button?.themedSizedTitle {
				actionButtonTitleLabel <~ StyleExtension.Label(buttonThemedTitle, for: currentUserInterfaceStyle)
			}
			
			actionButton.isUserInteractionEnabled = block.button != nil
		}
	}
}
