//
//  СopyableThemedTextView.swift
//  AlfaStrah
//
//  Created by Vitaly Trofimov on 23.12.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

import Foundation

extension BDUI {
	class СopyableThemedTextView: UIView {
		let block: СopyableThemedTextComponentDTO
		
		required init(block: СopyableThemedTextComponentDTO) {
			self.block = block
			
			super.init(frame: .zero)
			
			setupUI()
		}
		
		required init?(coder aDecoder: NSCoder) {
			fatalError("init(coder:) has not been implemented")
		}
		
		private let textLabel = UILabel()
		private let valueCopyButton = UIButton(type: .system)
		
		private func setupUI() {
			textLabel.numberOfLines = 0
			addSubview(textLabel)
			textLabel.edgesToSuperview(excluding: .trailing)
			textLabel <~ Style.Label.primaryText
			
			valueCopyButton.addTarget(
				self,
				action: #selector(copyText),
				for: .touchUpInside
			)
			addSubview(valueCopyButton)
			valueCopyButton.height(24)
			valueCopyButton.width(24)
			valueCopyButton.leadingToTrailing(
				of: textLabel,
				offset: 2
			)
			valueCopyButton.trailingToSuperview(relation: .equalOrLess)
			
			let offset = (textLabel.font.ascender + textLabel.font.descender) * 0.5
			valueCopyButton.centerY(to: textLabel, textLabel.firstBaselineAnchor, offset: -offset)
			
			valueCopyButton.isHidden = !block.isCopyable
			
			updateTheme()
		}
		
		@objc private func copyText(_ sender: UIButton) {
			UIPasteboard.general.string = textLabel.text
			
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
		
		// MARK: - Dark Theme Support
		override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
			super.traitCollectionDidChange(previousTraitCollection)
			
			updateTheme()
		}
		
		private func updateTheme() {
			let currentUserInterfaceStyle = traitCollection.userInterfaceStyle
			
			if let text = block.themedText {
				textLabel <~ BDUI.StyleExtension.Label(text, for: currentUserInterfaceStyle)
			}
			
			let iconImage = UIImage.Icons.copy
				.resized(newWidth: 24, insets: insets(4))?
				.tintedImage(withColor: block.iconColor?.color(for: currentUserInterfaceStyle) ?? .Icons.iconSecondary)
			
			valueCopyButton.setBackgroundImage(iconImage, for: .normal)
		}
	}
}
