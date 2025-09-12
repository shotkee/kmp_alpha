//
//  LinkedTextWidgetView.swift
//  AlfaStrah
//
//  Created by vit on 09.09.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

extension BDUI {
	class LinkedTextWidgetView: WidgetView<LinkedTextWidgetDTO> {
		private let inlineTextButtonsView = InlineTextButtonsView()
		
		required init(
			block: LinkedTextWidgetDTO,
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
			addSubview(inlineTextButtonsView)
			inlineTextButtonsView.edgesToSuperview(
				insets: UIEdgeInsets(top: 0, left: self.horizontalInset, bottom: 0, right: self.horizontalInset)
			)
			
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
			
			inlineTextButtonsView.backgroundColor = block.themedBackgroundColor?.color(for: currentUserInterfaceStyle)
			
			inlineTextButtonsView.set(
				buttons: block.text ?? [],
				userIntefaceStyle: currentUserInterfaceStyle,
				handleEvent: { events in
					self.handleEvent?(events)
				}
			)
		}
	}
	
	class InlineTextButtonsView: UITextView, UITextViewDelegate {
		private var buttons: [ InlineWidgetButtonComponentDTO ] = []
		
		private var handleEvent: ((EventsDTO) -> Void)?
		
		required init?(coder aDecoder: NSCoder) {
			super.init(coder: aDecoder)
			
			setup()
		}
		
		override init(frame: CGRect, textContainer: NSTextContainer?) {
			super.init(frame: frame, textContainer: textContainer)
			
			setup()
		}
		
		private func setup() {
			delegate = self
			isEditable = false
			isSelectable = true
			isScrollEnabled = false
			
			backgroundColor = .clear
			
			linkTextAttributes = [:]	// clear default link attributes
		}
		
		private typealias LinkEntry = (InlineWidgetButtonComponentDTO, NSRange)
		
		private var linkEntries: [LinkEntry] = []
		
		func set(
			buttons: [InlineWidgetButtonComponentDTO],
			userIntefaceStyle: UIUserInterfaceStyle,
			handleEvent: @escaping (EventsDTO) -> Void
		) {
			linkEntries.removeAll()
			
			let attributedString = NSMutableAttributedString()
			
			for button in buttons {
				if let themedSizedTitle = button.themedSizedTitle {
					if let mutableString = Self.mutableString(from: themedSizedTitle, with: Style.Font.text, for: userIntefaceStyle) {
						if button.events != nil {
							let range = NSRange(location: 0, length: mutableString.string.count)
							mutableString.addAttribute(.link, value: URL(fileURLWithPath: ""), range: range) // fake url path for button event handling
							
							linkEntries.append((button, NSRange(location: attributedString.string.count, length: mutableString.string.count)))
						}
						
						attributedString.append(mutableString)
					}
				}
			}
			
			attributedText = attributedString
			
			self.handleEvent = handleEvent
		}
		
		static func mutableString(
			from block: ThemedSizedTextComponentDTO,
			with defaultFont: UIFont,
			for currentUserInterfaceStyle: UIUserInterfaceStyle
		) -> NSMutableAttributedString? {
			guard let text = block.text
			else { return nil }
			
			let attributedText = NSMutableAttributedString(string: text)
			
			let range = NSRange(location: 0, length: text.count)
			
			if let foregroundColor = block.themedColor?.color(for: currentUserInterfaceStyle) {
				attributedText.addAttribute(
					.foregroundColor,
					value: foregroundColor,
					range: range
				)
			}
			
			if let underlineType = block.underlineType {
				attributedText.addAttribute(
					.underlineStyle,
					value: underlineStyle(underlineType),
					range: range
				)
				
				if let underlineColor = block.underlineColor?.color(for: currentUserInterfaceStyle) {
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
		
		private static func underlineStyle(_ type: ThemedSizedTextComponentDTO.LineType) -> NSUnderlineStyle {
			return .single
		}
		
		// MARK: - UITextViewDelegate
		func textView(
			_ textView: UITextView,
			shouldInteractWith url: URL,
			in characterRange: NSRange,
			interaction: UITextItemInteraction
		) -> Bool {
			if let linkEntry = linkEntries.first(where: { $0.1 == characterRange }),
			   let events = linkEntry.0.events{
				self.handleEvent?(events)
			}
			
			return false
		}
		
		func textViewDidChangeSelection(_ textView: UITextView) {
			textView.selectedTextRange = nil
		}
	}
}
