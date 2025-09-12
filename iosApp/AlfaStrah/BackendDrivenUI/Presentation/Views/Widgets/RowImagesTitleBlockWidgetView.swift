//
//  RowImagesTitleBlockWidgetView.swift
//  AlfaStrah
//
//  Created by vit on 28.08.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

extension BDUI {
	class RowImagesTitleBlockWidgetView: WidgetView<RowImagesTitleBlockWidgetDTO> {
		private let cardView = CardView()
		private let contentStackView = UIStackView()
		private let titleLabel = UILabel()
		private let itemsStackView = UIStackView()
		
		required init(
			block: RowImagesTitleBlockWidgetDTO,
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
			contentStackView.isLayoutMarginsRelativeArrangement = true
			contentStackView.layoutMargins = insets(18)
			contentStackView.alignment = .fill
			contentStackView.distribution = .fill
			contentStackView.axis = .vertical
			contentStackView.spacing = 0
			contentStackView.backgroundColor = .clear
			
			cardView.set(content: contentStackView)
			
			addSubview(cardView)
			cardView.leadingToSuperview(offset: horizontalInset)
			cardView.topToSuperview()
			cardView.trailingToSuperview(offset: horizontalInset)
			cardView.bottomToSuperview()
			
			titleLabel.numberOfLines = 0
			titleLabel <~ Style.Label.primaryTitle2
			titleLabel.text = block.title?.text
			
			contentStackView.addArrangedSubview(titleLabel)
			
			if let items = block.items {
				contentStackView.addArrangedSubview(spacer(15))
				setupItemsSection()
			}
			
			updateTheme()
		}
		
		private func setupItemsSection() {
			itemsStackView.isLayoutMarginsRelativeArrangement = true
			itemsStackView.alignment = .fill
			itemsStackView.distribution = .fillEqually
			itemsStackView.axis = .horizontal
			itemsStackView.spacing = 0
			
			contentStackView.addArrangedSubview(itemsStackView)
		}
		
		private func createItemView(_ item: RowImagesTitleBlockItemComponentDTO) -> UIStackView {
			let stackView = UIStackView()
			stackView.alignment = .center
			stackView.distribution = .fill
			stackView.axis = .vertical
			stackView.spacing = 3
			
			let imageViewContainer = UIView()
			let imageView = UIImageView()
			imageView.contentMode = .scaleAspectFill
			
			imageViewContainer.addSubview(imageView)
			
			stackView.addArrangedSubview(imageViewContainer)
			imageView.width(50)
			imageView.heightToWidth(of: imageView)
			imageView.edgesToSuperview()
			
			let currentUserInterfaceStyle = traitCollection.userInterfaceStyle
			
			let description = UILabel() <~ Style.Label.primaryCaption1
			description.textColor = item.title?.themedColor?.color(for: currentUserInterfaceStyle)
			
			description.numberOfLines = 0
			description.textAlignment = .center
			description.text = item.title?.text
			stackView.addArrangedSubview(description)
			
			imageView.sd_setImage(
				with: item.image?.url(for: currentUserInterfaceStyle),
				placeholderImage: nil
			)
			
			return stackView
		}
		
		@objc private func viewTap() {
			if let events = block.events {
				handleEvent?(events)
			}
		}
		
		override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
			super.traitCollectionDidChange(previousTraitCollection)
			
			updateTheme()
		}
		
		private func updateTheme() {
			let currentUserInterfaceStyle = traitCollection.userInterfaceStyle
			
			let backgroundColor = block.themedBackgroundColor?.color(for: currentUserInterfaceStyle) ?? .Background.backgroundSecondary
			cardView.contentColor = backgroundColor
			contentStackView.backgroundColor = backgroundColor
			
			titleLabel.textColor = block.title?.themedColor?.color(for: currentUserInterfaceStyle)
			
			if let items = block.items {
				itemsStackView.subviews.forEach({ $0.removeFromSuperview() })
				
				for item in items {
					let column = createItemView(item)
					itemsStackView.addArrangedSubview(column)
				}
			}
		}
	}
}
