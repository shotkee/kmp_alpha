//
//  AlignLeftOneButtonDescriptionHeaderView.swift
//  AlfaStrah
//
//  Created by vit on 19.08.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

import SDWebImage
import TinyConstraints

extension BDUI {
	class AlignLeftOneButtonDescriptionHeaderView: HeaderView<AlignLeftOneButtonDescriptionHeaderDTO> {
		private let titleLabel = UILabel()
		private let descriptionLabel = UILabel()
		private let actionButton = UIButton(type: .system)
		private let actionButtonTitleLabel = UILabel()
		
		private lazy var titleBottomConstraint: Constraint = {
			return titleLabel.bottomToSuperview(relation: .equalOrLess)
		}()
		
		required init(
			block: AlignLeftOneButtonDescriptionHeaderDTO,
			horizontalInset: CGFloat = 0,
			handleEvent: @escaping (EventsDTO) -> Void
		) {
			super.init(block: block, horizontalInset: horizontalInset, handleEvent: handleEvent)
			
			setupUI()
		}
		
		required init?(coder: NSCoder) {
			fatalError("init(coder:) has not been implemented")
		}
		
		private func setupUI() {
			setupTitle()
			setupActionButton()
			
			if block.themedSizedDescription != nil {
				setupDescription()
			} else {
				titleBottomConstraint.isActive = true
			}
			
			updateTheme()
		}
		
		private func setupTitle() {
			addSubview(titleLabel)
			titleLabel.numberOfLines = 0
			titleLabel <~ Style.Label.primaryTitle1
			titleLabel.leadingToSuperview()
			titleLabel.topToSuperview(relation: .equalOrGreater)
		}
		
		private func setupDescription() {
			addSubview(descriptionLabel)
			descriptionLabel.numberOfLines = 0
			descriptionLabel <~ Style.Label.secondarySubhead
			descriptionLabel.leadingToSuperview()
			descriptionLabel.topToBottom(of: titleLabel, offset: 6)
			descriptionLabel.bottomToSuperview(offset: -23)
			descriptionLabel.trailingToSuperview()
		}
		
		private func setupActionButton() {
			addSubview(actionButton)
			
			actionButton.trailingToSuperview()
			
			actionButton.leadingToTrailing(of: titleLabel, offset: 8)
			
			actionButton.centerY(to: titleLabel.forFirstBaselineLayout)
			
			actionButton.topToSuperview(relation: .equalOrGreater)
			actionButton.bottomToSuperview(relation: .equalOrLess)
			
			actionButton.addTarget(self, action: #selector(buttonTap), for: .touchUpInside)
			
			if let buttonThemedImage = block.rightButton?.themedImage {
				actionButton.height(24)
				actionButton.widthToHeight(of: actionButton)
				actionButton.contentMode = .scaleAspectFit
			} else if let rightButton = block.rightButton?.themedSizedTitle {
				actionButton.addSubview(actionButtonTitleLabel)
				actionButtonTitleLabel <~ Style.Label.accentText
				
				actionButtonTitleLabel.numberOfLines = 1
				actionButtonTitleLabel.edgesToSuperview()
			}
		}
		
		@objc private func buttonTap() {
			if let events = block.rightButton?.events {
				handleEvent(events)
			}
		}
		
		override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
			super.traitCollectionDidChange(previousTraitCollection)
			
			updateTheme()
		}
		
		private func updateTheme() {
			let currentUserInterfaceStyle = traitCollection.userInterfaceStyle
			
			if let themedSizedTitle = block.themedSizedTitle {
				titleLabel <~ BDUI.StyleExtension.Label(themedSizedTitle, for: currentUserInterfaceStyle)
			}
			
			if let themedSizedDescription = block.themedSizedDescription {
				descriptionLabel <~ BDUI.StyleExtension.Label(themedSizedDescription, for: currentUserInterfaceStyle)
			}
			
			if let buttonThemedImage = block.rightButton?.themedImage {
				SDWebImageManager.shared.loadImage(
					with: buttonThemedImage.url(for: currentUserInterfaceStyle),
					options: .highPriority,
					progress: nil,
					completed: { image, _, _, _, _, _ in
						self.actionButton.setImage(image, for: .normal)
					}
				)
			}
			
			if let buttonThemedTitle = block.rightButton?.themedSizedTitle {
				actionButtonTitleLabel <~ BDUI.StyleExtension.Label(buttonThemedTitle, for: currentUserInterfaceStyle)
			}
		}
	}
}
