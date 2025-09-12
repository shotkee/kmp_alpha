//
//  InsuranceWidgetView.swift
//  AlfaStrah
//
//  Created by vit on 15.04.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

extension BDUI {
	class InsuranceWidgetView: WidgetView<InsuranceWidgetDTO> {
		private let containerView = UIView()
		private let titleLabel = UILabel()
		private let iconImageView = UIImageView()
		private let textLabel = UILabel()
		private let contentView = UIStackView()
		
		required init(
			block: InsuranceWidgetDTO,
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
			let contentStackView = UIStackView()
			containerView.addSubview(contentStackView)
			
			contentStackView.isLayoutMarginsRelativeArrangement = true
			contentStackView.layoutMargins = .zero
			contentStackView.alignment = .fill
			contentStackView.distribution = .fill
			contentStackView.axis = .vertical
			contentStackView.spacing = 12
			contentStackView.backgroundColor = .clear
			
			contentStackView.edgesToSuperview(insets: insets(16))
			
			if let title = block.title {
				titleLabel.numberOfLines = 0
				titleLabel.text = title.text
				
				contentStackView.addArrangedSubview(titleLabel)
			}
			
			if let content = block.content, !content.isEmpty {
				contentView.isLayoutMarginsRelativeArrangement = true
				contentView.layoutMargins = .zero
				contentView.alignment = .leading
				contentView.distribution = .fill
				contentView.axis = .horizontal
				contentView.spacing = 2
				contentView.backgroundColor = .clear
				
				contentStackView.addArrangedSubview(contentView)
			}
			
			if let footer = block.footer {
				let footerContainerView = UIView()
				
				textLabel.numberOfLines = 0
				textLabel.text = footer.text?.text
				
				footerContainerView.addSubview(iconImageView)
				footerContainerView.addSubview(textLabel)
				
				iconImageView.width(16)
				iconImageView.heightToWidth(of: iconImageView)
				
				iconImageView.leadingToSuperview()
				iconImageView.topToSuperview(relation: .equalOrGreater)
				iconImageView.bottomToSuperview(relation: .equalOrLess)
				
				iconImageView.centerY(to: textLabel.forFirstBaselineLayout)
				
				textLabel.topToSuperview(relation: .equalOrGreater)
				textLabel.bottomToSuperview(relation: .equalOrLess)
				
				textLabel.leadingToTrailing(of: iconImageView, offset: 4)
				textLabel.trailingToSuperview()
				
				contentStackView.addArrangedSubview(footerContainerView)
			}
			
			let cardView = containerView.embedded(
				margins: UIEdgeInsets(top: 0, left: horizontalInset, bottom: 0, right: horizontalInset),
				hasShadow: true,
				cornerRadius: 16
			)
			
			addSubview(cardView)
			cardView.edgesToSuperview()
			
			updateTheme()
		}
		
		private func createContentElementView(_ widget: InsuranceContentComponentDTO) -> UIStackView {
			let currentUserInterfaceStyle = traitCollection.userInterfaceStyle
			
			let contentStackView = UIStackView()
			contentStackView.isLayoutMarginsRelativeArrangement = true
			contentStackView.layoutMargins = .zero
			contentStackView.alignment = .fill
			contentStackView.distribution = .fill
			contentStackView.axis = .vertical
			contentStackView.spacing = 2
			contentStackView.backgroundColor = .clear
			
			if let header = widget.header {
				let headerLabel = UILabel()
				headerLabel.numberOfLines = 0
				
				headerLabel.text = header.text
				
				let color = header.themedColor?
					.color(for: currentUserInterfaceStyle) ?? .Text.textContrast
				
				headerLabel <~ Style.Label.ColoredLabel(titleColor: color, font: Style.Font.caption1)
				contentStackView.addArrangedSubview(headerLabel)
			}
			
			if let value = widget.value {
				let valueCopyButton = UIButton(type: .system)
				valueCopyButton.setTitle(value.text, for: .normal)
				
				let color = value.themedColor?
					.color(for: currentUserInterfaceStyle) ?? .Text.textContrast
				
				valueCopyButton.setTitleColor(color, for: .normal)
				valueCopyButton.titleLabel?.font = Style.Font.subhead
				
				valueCopyButton.semanticContentAttribute = .forceRightToLeft
				valueCopyButton.titleLabel?.adjustsFontSizeToFitWidth = true
				
				valueCopyButton.tintColor = color
				valueCopyButton.addTarget(self, action: #selector(copyText), for: .touchUpInside)
				
				valueCopyButton.isUserInteractionEnabled = widget.isCopyable
				
				let image = widget.isCopyable
				? .Icons.copy.resized(newWidth: 20) ?? UIImage()
				: UIImage.backgroundImage(withColor: .clear, size: CGSize(width: 20, height: 20))
				
				valueCopyButton.setImage( image, for: .normal)
				
				contentStackView.addArrangedSubview(valueCopyButton)
			}
			
			return contentStackView
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
		
		override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
			super.traitCollectionDidChange(previousTraitCollection)
			
			updateTheme()
		}
		
		private func updateTheme() {
			let currentUserInterfaceStyle = traitCollection.userInterfaceStyle
			
			contentView.subviews.forEach({ $0.removeFromSuperview() })
			
			containerView.backgroundColor = block.themedBackgroundColor?
				.color(for: currentUserInterfaceStyle) ?? .Background.backgroundAccent
			
			if let title = block.title {
				let color = title.themedColor?
					.color(for: currentUserInterfaceStyle) ?? .Text.textContrast
				
				titleLabel <~ Style.Label.ColoredLabel(titleColor: color, font: Style.Font.headline1)
			}
			
			if let footer = block.footer {
				iconImageView.sd_setImage(with: footer.themedIcon?.url(for: currentUserInterfaceStyle))
				
				let color = footer.text?.themedColor?
					.color(for: currentUserInterfaceStyle) ?? .Text.textContrast
				
				textLabel <~ Style.Label.ColoredLabel(titleColor: color, font: Style.Font.subhead)
			}
			
			if let content = block.content, !content.isEmpty {
				for widget in content {
					contentView.addArrangedSubview(createContentElementView(widget))
				}
				
				let spacer = UIView()
				spacer.setContentHuggingPriority(.defaultLow, for: .horizontal)
				contentView.addArrangedSubview(spacer)
			}
		}
	}
}
