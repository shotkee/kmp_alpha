//
//  SectionViewWidget.swift
//  AlfaStrah
//
//  Created by vit on 22.07.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

extension BDUI {
	class SectionViewWidget: WidgetView<TextButtonArrowWidgetDTO> {		
		private let cardView = CardView()
		private let contentStackView = UIStackView()
		
		private let headerView = UIView()
		private let typeIconImageView = UIImageView()
		private let titleLabel = UILabel()
		private let favouriteIconButton = UIButton(type: .system)
		private let arrowAccessoryView = UIImageView()
		
		private let descriptionStackView = UIStackView()
		private let menuStackView = UIStackView()
		private let actionButtonsStackView = UIStackView()
		
		private var menuButtonActions: [(UIButton, EventsDTO?)] = []
		
		required init(
			block: TextButtonArrowWidgetDTO,
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
			contentStackView.layoutMargins = UIEdgeInsets(top: 20, left: 15, bottom: 20, right: 15)
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
			
			setupHeader()
			
			if block.textRows?.isEmpty ?? true == false {
				contentStackView.addArrangedSubview(spacer(5))
				setupDescription()
			}
			
			if block.menuButtons?.isEmpty ?? true == false {
				contentStackView.addArrangedSubview(spacer(15))
				setupMenu()
			}
			
			if block.actionButtons?.isEmpty ?? true == false {
				contentStackView.addArrangedSubview(spacer(15))
				setupActionButtons()
			}
			
			updateTheme()
		}
		
		private func setupHeader() {
			contentStackView.addArrangedSubview(headerView)
			
			if block.themedTitleIcon != nil {
				typeIconImageView.contentMode = .scaleAspectFit
				typeIconImageView.height(20)
				typeIconImageView.width(20)
				headerView.addSubview(typeIconImageView)
				typeIconImageView.leadingToSuperview()
			}
			
			titleLabel.numberOfLines = 0
			titleLabel <~ Style.Label.primaryHeadline1
			titleLabel.text = block.themedTitle?.text
			headerView.addSubview(titleLabel)
			titleLabel.topToSuperview()
			titleLabel.bottomToSuperview()
			
			let offset = (titleLabel.font.ascender + titleLabel.font.descender) * 0.5
			
			if block.themedTitleIcon != nil {
				titleLabel.leadingToTrailing(of: typeIconImageView, offset: 6)
				typeIconImageView.centerY(to: titleLabel, titleLabel.firstBaselineAnchor, offset: -offset)
			} else {
				titleLabel.leadingToSuperview()
			}
			
			headerView.addSubview(favouriteIconButton)
			favouriteIconButton.height(20)
			favouriteIconButton.width(20)
			favouriteIconButton.leadingToTrailing(of: titleLabel, offset: 15)
			favouriteIconButton.centerY(to: titleLabel, titleLabel.firstBaselineAnchor, offset: -offset)
			favouriteIconButton.addTarget(self, action: #selector(favouriteIconButtonTap), for: .touchUpInside)
			
			headerView.addSubview(arrowAccessoryView)
			arrowAccessoryView.height(20)
			arrowAccessoryView.width(20)
			arrowAccessoryView.leadingToTrailing(of: favouriteIconButton, offset: 4)
			arrowAccessoryView.trailingToSuperview()
			arrowAccessoryView.centerY(to: titleLabel, titleLabel.firstBaselineAnchor, offset: -offset)
		}
		
		private func setupDescription() {
			descriptionStackView.isLayoutMarginsRelativeArrangement = true
			descriptionStackView.layoutMargins = .zero
			descriptionStackView.alignment = .fill
			descriptionStackView.distribution = .fill
			descriptionStackView.axis = .vertical
			descriptionStackView.spacing = 5
			descriptionStackView.backgroundColor = .clear
			
			contentStackView.addArrangedSubview(descriptionStackView)
		}
		
		private func setupMenu() {
			menuStackView.isLayoutMarginsRelativeArrangement = true
			menuStackView.layoutMargins = .zero
			menuStackView.alignment = .fill
			menuStackView.distribution = .fill
			menuStackView.axis = .vertical
			menuStackView.spacing = 5
			menuStackView.backgroundColor = .clear
			
			contentStackView.addArrangedSubview(menuStackView)
		}
		
		private func setupActionButtons() {
			actionButtonsStackView.isLayoutMarginsRelativeArrangement = true
			actionButtonsStackView.layoutMargins = .zero
			actionButtonsStackView.alignment = .fill
			actionButtonsStackView.distribution = .fill
			actionButtonsStackView.axis = .vertical
			actionButtonsStackView.spacing = 5
			actionButtonsStackView.backgroundColor = .clear
			
			contentStackView.addArrangedSubview(actionButtonsStackView)
		}
		
		@objc private func viewTap() {
			if let events = block.events {
				handleEvent?(events)
			}
		}
		
		@objc private func favouriteIconButtonTap() {
			if let events = block.rightTopIcon?.events {
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
			
			typeIconImageView.sd_setImage(with: block.themedTitleIcon?.url(for: currentUserInterfaceStyle))
			
			titleLabel.textColor = block.themedTitle?.themedColor?.color(for: currentUserInterfaceStyle) ?? .Text.textPrimary
			
			favouriteIconButton.sd_setBackgroundImage(with: block.rightTopIcon?.themedIcon?.url(for: currentUserInterfaceStyle), for: .normal)
			
			let color = block.arrow?.themedColor?.color(for: currentUserInterfaceStyle) ?? .Icons.iconSecondary
			
			arrowAccessoryView.image = .Icons.chevronSmallRight.resized(newWidth: 20)?.tintedImage(withColor: color)
			
			if let textRows = block.textRows {
				descriptionStackView.subviews.forEach({ $0.removeFromSuperview() })
				
				for textRow in textRows {
					let rowView = UIView()
					
					let textLabel = UILabel()
					rowView.addSubview(textLabel)
					textLabel.edgesToSuperview(excluding: .trailing)
					
					textLabel <~ Style.Label.secondaryText
					textLabel.numberOfLines = 0
					textLabel.textColor = textRow.themedText?.themedColor?.color(for: currentUserInterfaceStyle)
					textLabel.text = textRow.themedText?.text
					
					if textRow.isCopyable {
						let valueCopyButton = UIButton(type: .system)
						valueCopyButton.addTarget(self, action: #selector(copyText), for: .touchUpInside)
						
						rowView.addSubview(valueCopyButton)
						
						valueCopyButton.height(24)
						valueCopyButton.width(24)
						valueCopyButton.leadingToTrailing(of: textLabel, offset: 4)
						valueCopyButton.trailingToSuperview(offset: 15, relation: .equalOrLess)
						
						let offset = (textLabel.font.ascender + textLabel.font.descender) * 0.5
						valueCopyButton.centerY(to: textLabel, textLabel.firstBaselineAnchor, offset: -offset)
						
						let iconImage: UIImage? = .Icons.copy.resized(newWidth: 24, insets: insets(4))?
							.tintedImage(withColor: textRow.iconColor?.color(for: currentUserInterfaceStyle) ?? .Icons.iconSecondary)
						valueCopyButton.setBackgroundImage(iconImage, for: .normal)
						
					}
					
					descriptionStackView.addArrangedSubview(rowView)
				}
			}
			
			if let menuButtons = block.menuButtons {
				menuStackView.subviews.forEach({ $0.removeFromSuperview() })
				
				for menuButton in menuButtons {
					if let paddingTop = menuButton.paddingTop,
					   paddingTop != 0 {
						menuStackView.addArrangedSubview(spacer(paddingTop))
					}
					
					let buttonContainer = UIButton(type: .system)
					
					buttonContainer.backgroundColor = menuButton.themedBackgroundColor?.color(for: currentUserInterfaceStyle)
					
					let borderColor = menuButton.themedBorderColor?.color(for: currentUserInterfaceStyle)?.cgColor
					buttonContainer.layer.borderColor = borderColor
					buttonContainer.layer.borderWidth = borderColor == nil ? 0 : 1
					
					buttonContainer.layer.cornerRadius = 12
					buttonContainer.layer.masksToBounds = true
					
					let iconImageView = UIImageView()
					buttonContainer.addSubview(iconImageView)
					iconImageView.height(24)
					iconImageView.width(24)
					iconImageView.leadingToSuperview(offset: 12)
					iconImageView.centerYToSuperview()
					iconImageView.sd_setImage(with: menuButton.themedIcon?.url(for: currentUserInterfaceStyle))
					
					let buttonTitleLabel = UILabel()
					buttonTitleLabel.textAlignment = .left
					buttonTitleLabel.numberOfLines = 0
					buttonTitleLabel <~ Style.Label.primaryButtonLarge
					buttonTitleLabel.text = menuButton.themedTitle?.text
					buttonTitleLabel.textColor = menuButton.themedTitle?.themedColor?.color(for: currentUserInterfaceStyle) ?? .Text.textPrimary
					buttonContainer.addSubview(buttonTitleLabel)
					
					buttonTitleLabel.leadingToTrailing(of: iconImageView, offset: 8)
					buttonTitleLabel.topToSuperview(offset: 17)
					buttonTitleLabel.bottomToSuperview(offset: -17)
					
					let accessoryArrowImageView = UIImageView()
					buttonContainer.addSubview(accessoryArrowImageView)
					let color = menuButton.arrow?.themedColor?.color(for: currentUserInterfaceStyle) ?? .Icons.iconSecondary
					accessoryArrowImageView.image = .Icons.chevronSmallRight.resized(newWidth: 20)?.tintedImage(withColor: color)
					accessoryArrowImageView.leadingToTrailing(of: buttonTitleLabel, offset: 8, relation: .equalOrGreater)
					accessoryArrowImageView.trailingToSuperview(offset: 12)
					accessoryArrowImageView.centerYToSuperview()
					
					menuStackView.addArrangedSubview(buttonContainer)
					
					if let paddingBottom = menuButton.paddingBottom,
					   paddingBottom != 0 {
						menuStackView.addArrangedSubview(spacer(paddingBottom))
					}
					
					buttonContainer.addTarget(self, action: #selector(menuButtonTap), for: .touchUpInside)
					
					menuButtonActions.append((buttonContainer, menuButton.events))
				}
			}
			
			if let actionButtons = block.actionButtons {
				actionButtonsStackView.subviews.forEach({ $0.removeFromSuperview() })
				
				for widgetDto in actionButtons {
					actionButtonsStackView.addArrangedSubview(
						ViewBuilder.constructWidgetView(
							for: widgetDto,
							handleEvent: { events in
								self.handleEvent?(events)
							}
						)
					)
				}
			}
		}
		
		@objc func copyText(_ sender: UIButton) {
			UIPasteboard.general.string = sender.currentTitle
			
			showStateInfoBanner(
				title: NSLocalizedString("common_copied", comment: ""),
				description: "",
				hasCloseButton: false,
				iconImage: .Icons.tick
					.tintedImage(withColor: .Icons.iconAccent)
					.withAlignmentRectInsets(insets(-4)),
				titleFont: Style.Font.text,
				appearance: .standard
			)
		}
		
		@objc func menuButtonTap(_ sender: UIButton) {
			if let buttonEntry = menuButtonActions.first(where: { $0.0 === sender }),
			   let events = buttonEntry.1 {
				self.handleEvent?(events)
			}
		}
	}
}
