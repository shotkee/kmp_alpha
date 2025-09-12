//
//  TextButtonCheckboxWidgetView.swift
//  AlfaStrah
//
//  Created by vit on 11.09.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

extension BDUI {
	class TextButtonCheckboxWidgetView: WidgetView<TextButtonCheckboxWidgetDTO> {
		private let cardView = CardView()
		private let titleLabel = UILabel()
		private let contentStackView = UIStackView()
		private let containerView = UIView()
		private let checkBoxButton = CommonCheckboxButton()
		
		required override init(
			block: TextButtonCheckboxWidgetDTO,
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
			addSubview(cardView)
			
			cardView.edgesToSuperview(insets: UIEdgeInsets(top: 0, left: self.horizontalInset, bottom: 0, right: self.horizontalInset))
			cardView.cornerRadius = 16
			cardView.set(content: containerView)
			
			titleLabel <~ Style.Label.primaryHeadline2
			
			contentStackView.isLayoutMarginsRelativeArrangement = true
			contentStackView.layoutMargins = UIEdgeInsets(top: 18, left: 15, bottom: 18, right: 0)
			contentStackView.alignment = .leading
			contentStackView.distribution = .fill
			contentStackView.axis = .vertical
			contentStackView.spacing = 5
			contentStackView.backgroundColor = .clear
			
			containerView.addSubview(contentStackView)
			contentStackView.edgesToSuperview(excluding: .trailing)
			
			containerView.addSubview(checkBoxButton)
			checkBoxButton.topToSuperview(offset: 18)
			checkBoxButton.trailingToSuperview(offset: 15)
			checkBoxButton.leadingToTrailing(of: contentStackView, offset: 8, relation: .equalOrGreater)
			
			checkBoxButton.isSelected = block.isSelected
			
			if block.isSelected {
				BDUI.FormDataOperations.addFormDataToCurrentScreenEntry(block.formData)
			}
			
			checkBoxButton.addTarget(self, action: #selector(checkboxTap), for: .touchUpInside)
			
			updateTheme()
		}
		
		@objc private func checkboxTap() {
			checkBoxButton.isSelected.toggle()
			
			if checkBoxButton.isSelected {
				BDUI.FormDataOperations.addFormDataToCurrentScreenEntry(block.formData)
			} else {
				BDUI.FormDataOperations.deleteFormDataFromCurrentScreenEntry(block.formData)
			}
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
			
			containerView.backgroundColor = block.themedBackgroundColor?.color(for: currentUserInterfaceStyle) ?? .Background.backgroundTertiary
			cardView.contentColor = block.themedBackgroundColor?.color(for: currentUserInterfaceStyle) ?? .Background.backgroundTertiary
			
			contentStackView.subviews.forEach({ $0.removeFromSuperview() })
			
			if let themedTitle = block.themedTitle {
				contentStackView.addArrangedSubview(titleLabel)
				
				titleLabel.text = themedTitle.text
				titleLabel.textColor = themedTitle.themedColor?.color(for: currentUserInterfaceStyle) ?? .Text.textPrimary
			}
			
			if let textRows = block.textRows {
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
					
					contentStackView.addArrangedSubview(rowView)
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
		
		private func createItemView(
			themedText: ThemedTextComponentDTO?,
			themedIcon: ThemedValueComponentDTO?
		) -> UIStackView {
			let currentUserInterfaceStyle = traitCollection.userInterfaceStyle
			
			let stackView = UIStackView()
			stackView.axis = .horizontal
			stackView.distribution = .fill
			stackView.alignment = .top
			stackView.spacing = 9
			
			if let themedIcon {
				let iconImageView = UIImageView()
				
				iconImageView.height(16)
				iconImageView.widthToHeight(of: iconImageView)
				
				iconImageView.sd_setImage(with: themedIcon.url(for: currentUserInterfaceStyle))
				
				stackView.addArrangedSubview(iconImageView)
			}
			
			if let themedText {
				let textItem = UILabel()
				textItem <~ Style.Label.primaryText
				textItem.textAlignment = .left
				textItem.text = themedText.text
				textItem.textColor = themedText.themedColor?.color(for: currentUserInterfaceStyle)
				
				textItem.numberOfLines = 0
				
				textItem.setContentHuggingPriority(.required, for: .horizontal)
				
				stackView.addArrangedSubview(textItem)
			}
			
			return stackView
		}
	}
}
