//
//  TitleIconsTextListWidgetView.swift
//  AlfaStrah
//
//  Created by Vitaly Trofimov on 23.12.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

import Foundation
import SDWebImage

extension BDUI {
	class TitleIconsTextListWidgetView: WidgetView<TitleIconsTextListWidgetDTO> {
		required init?(coder aDecoder: NSCoder) {
			fatalError("init(coder:) has not been implemented")
		}
		
		required init(
			block: TitleIconsTextListWidgetDTO,
			horizontalInset: CGFloat = 18,
			handleEvent: @escaping (EventsDTO) -> Void
		) {
			super.init(block: block, horizontalInset: horizontalInset, handleEvent: handleEvent)
			
			setupUI()
			setupTapGestureRecognizer()
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
		
		private let backgroundImageView = UIImageView()
		private lazy var backgroundImageViewHeightConstraint: NSLayoutConstraint = {
			return backgroundImageView.height(0)
		}()
		
		private let iconImageView = UIImageView()
		private let editButton = UIButton(type: .custom)
		private let titleLabel = UILabel()
		
		private func setupUI() {
			// background
			layer.cornerRadius = 20
			
			// background image
			addSubview(backgroundImageView)
			backgroundImageView.centerInSuperview()
			backgroundImageView.aspectRatio(1)
			
			// icon
			iconImageView.contentMode = .scaleAspectFit
			addSubview(iconImageView)
			iconImageView.topToSuperview(offset: 16)
			iconImageView.leadingToSuperview(offset: 16)
			iconImageView.width(32)
			iconImageView.aspectRatio(1)
			
			// edit button
			editButton.imageView?.contentMode = .scaleAspectFit
			addSubview(editButton)
			editButton.topToSuperview(offset: 22)
			editButton.trailingToSuperview(offset: 16)
			editButton.width(20)
			editButton.aspectRatio(1)
			editButton.addTarget(self, action: #selector(rightIconTap), for: .touchDown)
			
			// title
			titleLabel <~ Style.Label.primaryHeadline1
			titleLabel.numberOfLines = 0
			addSubview(titleLabel)
			titleLabel.topToSuperview(offset: 22)
			titleLabel.leadingToTrailing(
				of: iconImageView,
				offset: 8
			)
			titleLabel.trailingToLeading(
				of: editButton,
				offset: -8
			)
			
			// top content
			let topContentStack = contentStack(for: block.topItems, spacing: 6)
			addSubview(topContentStack)
			topContentStack.topToBottom(
				of: titleLabel,
				offset: 30
			)
			topContentStack.horizontalToSuperview(insets: .horizontal(16))
			
			// bottom content
			let bottomContentStack = contentStack(for: block.bottomItems, spacing: 12)
			
			addSubview(bottomContentStack)
			bottomContentStack.edgesToSuperview(excluding: .top, insets: .uniform(16))
			bottomContentStack.topToBottom(of: topContentStack, offset: 20, relation: .equalOrGreater)
		}
		
		private func contentStack(for items: [TitleIconsTextListItemComponentDTO]?, spacing: CGFloat) -> UIStackView {
			let contentStack = UIStackView()
			contentStack.axis = .vertical
			contentStack.spacing = spacing
			
			if let items = items {
				let topContents: [(CGFloat, TitleIconsTextListContentView)] = items.map {
					let itemView = TitleIconsTextListContentView(block: $0)
					return ($0.width, itemView)
				}
				
				var rowLength: CGFloat = 0.0
				var rowStackView = UIStackView()
				
				for itemEntry in topContents {
					if rowLength <= 0 {
						rowStackView = UIStackView()
						rowStackView.axis = .horizontal
						rowStackView.spacing = 8
						rowStackView.distribution = .fillEqually
						contentStack.addArrangedSubview(rowStackView)
						
						rowLength = 1
					}
					
					rowLength -= itemEntry.0
					rowStackView.addArrangedSubview(itemEntry.1)
					
				}
			}
			
			return contentStack
		}
		
		@objc private func rightIconTap() {
			if let events = block.rightIcon?.events {
				handleEvent?(events)
			}
		}
		
		// MARK: - Dark Theme Support
		override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
			super.traitCollectionDidChange(previousTraitCollection)
			
			updateTheme()
		}
		
		private func updateTheme() {
			let currentUserInterfaceStyle = traitCollection.userInterfaceStyle
			
			backgroundColor = block.themedBackgroundColor?.color(for: currentUserInterfaceStyle)
			
			backgroundImageView.sd_setImage(
				with: block.image?.url(for: currentUserInterfaceStyle),
				placeholderImage: nil,
				completed: { [weak self] image, err, _, _ in
					guard let self
					else { return }
					
					if let image, err == nil {
						self.backgroundImageViewHeightConstraint.constant = image.size.height * 0.34
					}
				}
			)
			
			iconImageView.sd_setImage(with: block.leftIcon?.url(for: currentUserInterfaceStyle))
			
			backgroundImageView.sd_setImage(
				with: block.image?.url(for: currentUserInterfaceStyle),
				placeholderImage: nil,
				completed: { [weak self] image, err, _, _ in
					guard let self
					else { return }
					
					if let image, err == nil {
						self.backgroundImageViewHeightConstraint.constant = image.size.height * 0.34
					}
				}
			)
			
			if let buttonImageUrl = block.rightIcon?.themedImage?.url(for: currentUserInterfaceStyle) {
				SDWebImageManager.shared.loadImage(
					with: buttonImageUrl,
					options: .highPriority,
					progress: nil,
					completed: { image, _, _, _, _, _ in
						self.editButton.setImage( image, for: .normal)
					}
				)
			}
			
			if let title = block.title {
				titleLabel <~ BDUI.StyleExtension.Label(title, for: currentUserInterfaceStyle)
			}
		}
	}
}
