//
//  RowImageHeaderDescriptionButtonWidgetView.swift
//  AlfaStrah
//
//  Created by vit on 30.07.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

extension BDUI {
	class RowImageHeaderDescriptionButtonWidgetView: WidgetView<RowImageHeaderDescriptionButtonWidgetDTO> {
		private let containerView = UIView()
		private let titleLabel = UILabel()
		private let amountLabel = UILabel()
		private let iconImageView = UIImageView()
		private let backgroundImageView = UIImageView()
		private let descriptionLabel = UILabel()
		
		private let horizontalStackView = UIStackView()
		private let cardView = CardView()
		private let widgetSelectorContainer = UIView()
		
		required init(
			block: RowImageHeaderDescriptionButtonWidgetDTO,
			horizontalInset: CGFloat = 18,
			handleEvent: @escaping (EventsDTO) -> Void
		) {
			super.init(block: block, horizontalInset: horizontalInset, handleEvent: handleEvent)
			
			setupUI()
		}
		
		required init?(coder aDecoder: NSCoder) {
			fatalError("init(coder:) has not been implemented")
		}
		
		private func setupTapGestureRecognizer() {
			let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(viewTap))
			addGestureRecognizer(tapGestureRecognizer)
		}
		
		private func setupContainerView() {
			containerView.backgroundColor = .Background.backgroundTertiary
			
			addSubview(cardView)
			cardView.edgesToSuperview(insets: UIEdgeInsets(top: 0, left: self.horizontalInset, bottom: 0, right: self.horizontalInset))
			
			cardView.cornerRadius = 16
			cardView.hideShadow = false
			cardView.set(content: containerView)
		}
		
		private func setupUI() {
			self.layer.masksToBounds = false
			self.clipsToBounds = false
			
			setupContainerView()
			
			containerView.addSubview(widgetSelectorContainer)
			widgetSelectorContainer.edgesToSuperview(excluding: .top)
			
			if let widgetDto = block.widgetDto {
				let view = ViewBuilder.constructWidgetView(
					for: widgetDto,
					handleEvent: { events in
						self.handleEvent?(events)
					}
				)
				
				widgetSelectorContainer.addSubview(view)
				view.edgesToSuperview(insets: UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16))
			}
			
			let stackView = UIStackView()
			stackView.axis = .vertical
			stackView.distribution = .fill
			stackView.alignment = .fill
			stackView.spacing = 0
			
			containerView.addSubview(stackView)
			stackView.topToSuperview(offset: 16)
			stackView.leadingToSuperview(offset: 16)
			stackView.bottomToTop(of: widgetSelectorContainer, relation: .equalOrLess)
			
			containerView.addSubview(backgroundImageView)
			backgroundImageView.height(120)
			backgroundImageView.widthToHeight(of: backgroundImageView)
			backgroundImageView.topToSuperview(offset: 12)
			backgroundImageView.trailingToSuperview(offset: 12)
			backgroundImageView.leadingToTrailing(of: stackView)
			backgroundImageView.bottomToTop(of: widgetSelectorContainer, offset: -7, relation: .equalOrLess)
			
			titleLabel.numberOfLines = 0
			titleLabel <~ Style.Label.primaryTitle2
			titleLabel.text = block.themedTitle?.text
			stackView.addArrangedSubview(titleLabel)
			
			horizontalStackView.axis = .horizontal
			horizontalStackView.distribution = .fill
			horizontalStackView.alignment = .leading
			horizontalStackView.spacing = 4
			horizontalStackView.layoutMargins = UIEdgeInsets(top: 4, left: 0, bottom: 0, right: 0)
			
			stackView.addArrangedSubview(horizontalStackView)
			
			amountLabel <~ Style.Label.primaryTitle2
			amountLabel.text = block.themedAmount?.text
			horizontalStackView.addArrangedSubview(amountLabel)
			
			iconImageView.width(18)
			iconImageView.height(24)
			iconImageView.contentMode = .scaleAspectFit
			horizontalStackView.addArrangedSubview(iconImageView)
			
			let spacerView = UIView()
			spacerView.setContentHuggingPriority(.defaultLow, for: .horizontal)
			horizontalStackView.addArrangedSubview(spacerView)
			
			stackView.addArrangedSubview(horizontalStackView)
			
			stackView.addArrangedSubview(spacer(10))
			
			descriptionLabel.numberOfLines = 0
			descriptionLabel <~ Style.Label.primarySubhead
			descriptionLabel.text = block.themedDescription?.text
			stackView.addArrangedSubview(descriptionLabel)
			
			updateTheme()
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
			
			cardView.contentColor = block.themedBackgroundColor?.color(for: currentUserInterfaceStyle) ?? .Background.backgroundTertiary
			
			backgroundImageView.sd_setImage(with: block.themedImage?.url(for: currentUserInterfaceStyle))
			
			titleLabel.textColor = block.themedTitle?.themedColor?.color(for: currentUserInterfaceStyle)
			
			if let amountText = block.themedAmount?.text {
				iconImageView.sd_setImage(with: block.themedIcon?.url(for: currentUserInterfaceStyle))
				amountLabel.textColor = block.themedAmount?.themedColor?.color(for: currentUserInterfaceStyle)
			} else {
				horizontalStackView.removeFromSuperview()
			}
			
			descriptionLabel.textColor = block.themedDescription?.themedColor?.color(for: currentUserInterfaceStyle)
		}
	}
}
