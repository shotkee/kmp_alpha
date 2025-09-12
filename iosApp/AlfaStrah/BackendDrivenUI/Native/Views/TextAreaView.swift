//
//  TextAreaView.swift
//  AlfaStrah
//
//  Created by vit on 20.11.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

import TinyConstraints

class TextAreaView: UITextView {
	enum State {
		case placeholder
		case text
	}
	
	private var state: State = .placeholder
	
	private let floatingLabel = UILabel()
	private let rightButton = UIButton(type: .system)
	
	private var placeholderText: String?
	private var attributedPlaceholderText: NSAttributedString?
	
	private var isEditing: Bool = false
				
	var floatingLabelAttributedText: NSAttributedString? {
		didSet {
			updateFloatingLabel()
		}
	}
		
	var placeholder: String? {
		didSet {
			switch state {
				case .placeholder:
					if isTextEmpty() {
						text = placeholder
					}
					
				case .text:
					break
					
			}
		}
	}
		
	var attributedPlaceholder: NSAttributedString? {
		didSet {
			switch state {
				case .placeholder:
					if isTextEmpty() {
						attributedText = attributedPlaceholder
					}
					
				case .text:
					break
					
			}
		}
	}
	
	override var text: String? {
		didSet {
			if !isTextEmpty() && !textIsPlaceholder() {
				state = .text
			} else {
				state = .placeholder
			}
			
			updateFloatingLabel()
			updateAppearance()
		}
	}
	
	override var attributedText: NSAttributedString? {
		didSet {
			if !isTextEmpty() && !textIsPlaceholder() {
				state = .text
			} else {
				state = .placeholder
			}
			
			updateFloatingLabel()
			updateAppearance()
		}
	}
	
	private func updatePadding() {
		let textPadding = UIEdgeInsets(
			top: floatingLabel.bounds.height + 11,
				  left: Constants.paddingText.left,
				  bottom: Constants.paddingText.bottom,
				  right: Constants.paddingText.right
			  )
		
		switch state {
			case .placeholder:
				if isTextEmpty() || textIsPlaceholder() {
					textContainerInset = Constants.paddingPlaceholderText
				} else {
					textContainerInset = textPadding
				}
				
			case .text:
				textContainerInset = textPadding
				
		}
	}
			
	override var isEditable: Bool {
		didSet {
			alpha = isEditable ? 1 : 0.4
		}
	}
		
	required init(style: Styles) {
		self.style = style
		self.appearance = self.style.abandoned
		self.appearanceType = .abandoned
		
		super.init(frame: .zero, textContainer: nil)
		
		setupUI()
		updateTheme()
				
		NotificationCenter.default.addObserver(
			self,
			selector: #selector(handleEditing),
			name: UITextView.textDidChangeNotification,
			object: self
		)
		
		NotificationCenter.default.addObserver(
			self,
			selector: #selector(handleBeginEditing),
			name: UITextView.textDidBeginEditingNotification,
			object: self
		)
		
		NotificationCenter.default.addObserver(
			self,
			selector: #selector(handleEndEditing),
			name: UITextView.textDidEndEditingNotification,
			object: self
		)
		
		defaultInputState()
	}
	
	private func defaultInputState() {
		switch state {
			case .placeholder:
				if isTextEmpty() {
					text = placeholder
					attributedText = attributedPlaceholder
				}
				
			case .text:
				break
				
		}
		
		updateAppearance()
	}
	
	deinit {
		NotificationCenter.default.removeObserver(self)
	}
	
	@objc func handleBeginEditing() {
		self.isEditing = true
		self.clearPlaceholderTextFromInputNextTimeWhenEdit = true
		
		switch state {
			case .placeholder:
				if textIsPlaceholder() {
					DispatchQueue.main.async {
						self.selectedRange = NSRange(location: 0, length: 0)
					}
				}
				
			case .text:
				break
				
		}
	}
	
	private var clearPlaceholderTextFromInputNextTimeWhenEdit = false
	
	@objc func handleEditing() {
		switch state {
			case .placeholder:
				if textIsPlaceholder() || clearPlaceholderTextFromInputNextTimeWhenEdit {
					attributedText = nil
					text = nil
					
					clearPlaceholderTextFromInputNextTimeWhenEdit = false
				}
				
				state = .text
				
			case .text:
				if isTextEmpty() {
					state = .placeholder
					
					text = placeholder
					attributedText = attributedPlaceholder
					
					clearPlaceholderTextFromInputNextTimeWhenEdit = true
					
					self.selectedRange = NSRange(location: 0, length: 0)
				}
		}
		
		updateFloatingLabel()
		updatePadding()
		updateAppearance()
	}
	
	@objc func handleEndEditing() {
		self.isEditing = false
		self.clearPlaceholderTextFromInputNextTimeWhenEdit = false
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		
		updatePadding()
	}
	
	private func setupUI() {
		autocorrectionType = .no // font color style switch fix
		
		translatesAutoresizingMaskIntoConstraints = false
		
		layer.cornerRadius = 10
		layer.masksToBounds = true
		
		layer.borderWidth = 1
		
		font = Style.Font.text
		
		floatingLabel.numberOfLines = 0
		
		addSubview(floatingLabel)
		floatingLabel.edgesToSuperview(excluding: .bottom, insets: UIEdgeInsets(top: 11, left: 15, bottom: 0, right: 15))
		floatingLabel.width(to: self, offset: -30)
						
		textContainer.lineFragmentPadding = .zero
		textContainerInset = .zero
		contentInset = .zero
	}
	
	private func updateFloatingLabel() {
		floatingLabel.attributedText = floatingLabelAttributedText
		
		switch state {
			case .placeholder:
				floatingLabel.isHidden = textIsPlaceholder() || isTextEmpty()
				
			case .text:
				floatingLabel.isHidden = false
		}
	}
	
	private func updateAppearance() {
		let currentInterfaceStyle = traitCollection.userInterfaceStyle
		
		layer.borderColor = appearance.borderColor?.color(for: currentInterfaceStyle)?.cgColor ?? UIColor.clear.cgColor
		
		let defaultColor: UIColor = state == .text ? .Text.textPrimary : .Text.textSecondary
		let color = state == .text
			? appearance.fontColor?.color(for: currentInterfaceStyle)
			: style.floating.fontColor?.color(for: currentInterfaceStyle)
		
		textColor = color ?? defaultColor
	}
	
	private func isTextEmpty() -> Bool {
		return (text?.isEmpty ?? true) || (attributedText?.string.isEmpty ?? true)
	}
	
	private func isPlaceholderEmpty() -> Bool {
		return (placeholder?.isEmpty ?? true) || (attributedPlaceholder?.string.isEmpty ?? true)
	}
	
	private func textIsPlaceholder() -> Bool {
		guard isPlaceholderEmpty()
		else { return true }
		
		return (placeholder == text) || (attributedText?.string == attributedPlaceholder?.string)
	}
	
	// MARK: - Dark Theme Support
	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
		
		updateTheme()
	}
	
	private func updateTheme() {
		let currentUserInterfaceStyle = traitCollection.userInterfaceStyle
		
		backgroundColor = appearance.backgroundColor?.color(for: currentUserInterfaceStyle)
		
		updateAppearance()
	}
	
	// MARK: - Appearance
	private var appearance: Appearance {
		didSet {
			updateAppearance()
		}
	}
	
	var appearanceType: AppearanceType {
		didSet {
			switch appearanceType {
				case .abandoned:
					appearance = style.abandoned
					
				case .selected:
					appearance = style.selected
					
				case .error:
					appearance = style.error
					
			}
		}
	}
	
	private let style: Styles
	
	struct Appearance {
		let borderColor: BDUI.ThemedValueComponentDTO?
		let fontColor: BDUI.ThemedValueComponentDTO?
		let backgroundColor: BDUI.ThemedValueComponentDTO?
	}
	
	struct Styles {
		let abandoned: Appearance
		let selected: Appearance
		let error: Appearance
		let floating: Appearance
	}
	
	enum AppearanceType {
		case abandoned
		case selected
		case error
	}
	
	struct Constants {
		static let paddingText = UIEdgeInsets(top: 24, left: 15, bottom: 10, right: 15)
		static let paddingPlaceholderText = UIEdgeInsets(top: 16, left: 15, bottom: 16, right: 15)
	}
}
