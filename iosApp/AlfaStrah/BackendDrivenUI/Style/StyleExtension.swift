//
//  StyleExtension.swift
//  AlfaStrah
//
//  Created by vit on 21.02.2025.
//  Copyright © 2025 Touch Instinct. All rights reserved.
//

extension BDUI {
	enum StyleExtension {
		struct Checkbox: Applicable {
			let block: iosApp.BDUI.CheckboxColorsComponentDTO?
			let userInterfaceStyle: UIUserInterfaceStyle
			
			init(
				_ block: iosApp.BDUI.CheckboxColorsComponentDTO?,
				for userInterfaceStyle: UIUserInterfaceStyle
			) {
				self.block = block
				self.userInterfaceStyle = userInterfaceStyle
			}
			
			func apply(_ object: UIButton) {
				object.setTitle("", for: .normal)
				
				object.layer.borderWidth = 1
				object.layer.borderColor = block?.borderColor?.color(for: userInterfaceStyle)?.cgColor ?? UIColor.clear.cgColor
				
				object.backgroundColor = block?.backgroundColor?.color(for: userInterfaceStyle) ?? .clear
				
				let selectedStateImage: UIImage = .Icons.tickForCheckbox.tintedImage(
					withColor: block?.tickColor?.color(for: userInterfaceStyle) ?? .clear
				)
		
				object.setImage(nil, for: .normal)
				object.setImage(selectedStateImage, for: .selected)
				object.setImage(selectedStateImage, for: [.selected, .disabled])
				object.setImage(nil, for: [.disabled])
			}
		}
		
		struct MultiStyleLabel: Applicable {
			let blocks: [iosApp.BDUI.ThemedSizedTextComponentDTO]
			let userInterfaceStyle: UIUserInterfaceStyle
			
			init(
				_ blocks: [iosApp.BDUI.ThemedSizedTextComponentDTO],
				for userInterfaceStyle: UIUserInterfaceStyle
			) {
				self.blocks = blocks
				self.userInterfaceStyle = userInterfaceStyle
			}
			
			func apply(_ object: UILabel) {
				let resultText = NSMutableAttributedString(string: "")
				
				for block in self.blocks {
					if let attributedText = StyleExtension.attributedText(
						from: block,
						for: self.userInterfaceStyle,
						with: object.font
					) {
						resultText.append(attributedText)
					}
				}
				
				object.attributedText = resultText
			}
		}
		
		struct Label: Applicable {
			let block: iosApp.BDUI.ThemedSizedTextComponentDTO
			let userInterfaceStyle: UIUserInterfaceStyle
			
			init(
				_ block: iosApp.BDUI.ThemedSizedTextComponentDTO,
				for userInterfaceStyle: UIUserInterfaceStyle
			) {
				self.block = block
				self.userInterfaceStyle = userInterfaceStyle
			}
			
			func apply(_ object: UILabel) {
				object.attributedText = StyleExtension.attributedText(from: block, for: self.userInterfaceStyle, with: object.font)
			}
		}
		
		struct AttributedString: Applicable {
			let block: iosApp.BDUI.ThemedSizedTextComponentDTO
			let userInterfaceStyle: UIUserInterfaceStyle
			let text: String?
			
			init(
				_ block: iosApp.BDUI.ThemedSizedTextComponentDTO,
				for userInterfaceStyle: UIUserInterfaceStyle,
				with text: String? = nil
			) {
				self.block = block
				self.userInterfaceStyle = userInterfaceStyle
				self.text = text
			}
			
			func apply(_ object: NSMutableAttributedString) {
				if let attributedText = StyleExtension.attributedText(
					from: block,
					for: userInterfaceStyle,
					with: Style.Font.text,
					use: self.text
				) {
					object.setAttributedString(attributedText)
				}
			}
		}
		
		private static func attributedText(
			from block: ThemedSizedTextComponentDTO,
			for userInterfaceStyle: UIUserInterfaceStyle,
			with defaultFont: UIFont,
			use defaultText: String? = nil
		) -> NSMutableAttributedString? {
			var text: String
			
			if let defaultText {
				text = defaultText
			} else if let blockText = block.text {
				text = blockText
			} else {
				return nil
			}
			
			let attributedText = NSMutableAttributedString(string: text)
			
			let range = NSRange(location: 0, length: text.count)
			let objectUserInterfaceStyle = userInterfaceStyle
			
			if let foregroundColor = block.themedColor?.color(for: objectUserInterfaceStyle) {
				attributedText.addAttribute(
					.foregroundColor,
					value: foregroundColor,
					range: range
				)
			}
			
			if let underlineType = block.underlineType {
				attributedText.addAttribute(
					.underlineStyle,
					value: StyleExtension.underlineStyle(underlineType),
					range: range
				)
				
				if let underlineColor = block.underlineColor?.color(for: objectUserInterfaceStyle) {
					attributedText.addAttribute(
						.underlineColor,
						value: underlineColor,
						range: range
					)
				}
			}
			
			var font: UIFont = defaultFont
			var symbolicTraits: UIFontDescriptor.SymbolicTraits = []
			
			if block.isBold ?? false {
				symbolicTraits.insert(.traitBold)
			}
			
			if block.isItalic ?? false {
				symbolicTraits.insert(.traitItalic)
				font = Style.Font.textItalic
			}
				
			if let modifiedFontDescriptor = font.fontDescriptor.withSymbolicTraits(symbolicTraits) {
				font = UIFont(descriptor: modifiedFontDescriptor, size: block.titleSize ?? font.pointSize)
				attributedText.addAttribute(.font, value: font, range: range)
			}
			
			return attributedText
		}
				
		private static func underlineStyle(_ type: iosApp.BDUI.ThemedSizedTextComponentDTO.LineType) -> NSUnderlineStyle {
			return .single
		}
	}
}
