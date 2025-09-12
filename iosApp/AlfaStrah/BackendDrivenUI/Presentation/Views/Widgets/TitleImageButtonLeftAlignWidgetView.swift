//
//  TitleImageButtonLeftAlignWidgetView.swift
//  AlfaStrah
//
//  Created by vit on 06.09.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

import TinyConstraints
import SDWebImage

extension BDUI {
	class TitleImageButtonLeftAlignWidgetView: WidgetView<TitleImageButtonLeftAlignWidgetDTO> {
		private let cardView = CardView()
		private let containerView = UIView()
		private let titleLabel = UILabel()
		private let descriptionLabel = UILabel()
		private let imageView = UIImageView()
		private let contentStackView = UIStackView()
		
		private lazy var imageAspectRatioConstraint: Constraint = {
			return imageView.aspectRatio(1)
		}()
		
		private lazy var contentStackViewTrailingConstraint: Constraint = {
			return contentStackView.trailingToSuperview(offset: 0)
		}()
		
		required override init(
			block: TitleImageButtonLeftAlignWidgetDTO,
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
			contentStackView.layoutMargins = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 0)
			contentStackView.alignment = .leading
			contentStackView.distribution = .fill
			contentStackView.axis = .vertical
			contentStackView.spacing = 0
			contentStackView.backgroundColor = .clear
			
			contentStackView.edgesToSuperview(excluding: .trailing)
			contentStackView.trailingToSuperview(offset: 130)
			
			if let title = block.title {
				titleLabel.numberOfLines = 0
				titleLabel.text = title.text
				titleLabel.setContentHuggingPriority(.required, for: .vertical)
				contentStackView.addArrangedSubview(titleLabel)
			}
			
			if let description = block.description {
				contentStackView.addArrangedSubview(spacer(4))
				
				descriptionLabel.numberOfLines = 0
				descriptionLabel.text = description.text
				descriptionLabel.setContentHuggingPriority(.required, for: .vertical)
				
				contentStackView.addArrangedSubview(descriptionLabel)
				
				contentStackView.addArrangedSubview(spacer(24))
			}
			
			if let widgetDto = block.button {
				let widgetView = ViewBuilder.constructWidgetView(
					for: widgetDto,
					handleEvent: { events in
						self.handleEvent?(events)
					}
				)
				
				contentStackView.addArrangedSubview(widgetView)
			}
			
			if let image = block.image {
				let imageContainerView = UIView()
				
				containerView.addSubview(imageContainerView)
				imageContainerView.leadingToTrailing(of: contentStackView)
				imageContainerView.trailingToSuperview()
				imageContainerView.verticalToSuperview()
				
				imageContainerView.addSubview(imageView)
				imageView.leadingToSuperview()
				imageView.trailingToSuperview()
				imageView.bottomToSuperview()
				imageView.contentMode = .scaleAspectFit
			}
			
			addSubview(cardView)
			
			cardView.edgesToSuperview()
			cardView.cornerRadius = 20
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
					.color(for: currentUserInterfaceStyle) ?? .Text.textContrast
				
				titleLabel <~ Style.Label.ColoredLabel(titleColor: color, font: Style.Font.headline1)
			}
			
			if let description = block.description {
				let color = description.themedColor?
					.color(for: currentUserInterfaceStyle) ?? .Text.textContrast
				
				descriptionLabel <~ Style.Label.ColoredLabel(titleColor: color, font: Style.Font.subhead)
			}
			
			if let image = block.image {
				SDWebImageManager.shared.loadImage(
					with: image.url(for: currentUserInterfaceStyle),
					options: .highPriority,
					progress: nil,
					completed: { image, _, _, _, _, _ in
						if let image {
							self.imageAspectRatioConstraint.constant = image.size.width / image.size.height
							self.imageView.image = image
						}
					}
				)
			}
		}
	}
}
