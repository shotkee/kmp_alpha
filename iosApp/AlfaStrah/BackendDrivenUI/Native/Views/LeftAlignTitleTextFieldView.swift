//
//  LeftAlignTitleTextFieldView.swift
//  AlfaStrah
//
//  Created by vit on 22.11.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

import TinyConstraints

class LeftAlignTitleTextFieldView: UITextField, TextInputBDUI {
	private let floatingLabel = UILabel()
	private let rightButton = UIButton(type: .system)
	
	private var placeholderText: String?
	private var attributedPlaceholderText: NSAttributedString?
	
	private lazy var floatingLabelCenterConstraint: Constraint = {
		let floatingLabelBaseLineOffset = ((floatingLabel.font?.ascender ?? 0) + (floatingLabel.font?.descender ?? 0)) * 0.5
		
		return floatingLabel.centerY(to: self, self.firstBaselineAnchor, offset: -floatingLabelBaseLineOffset)
	}()
		
	var showRightButton = false {
		didSet {
			rightViewMode = showRightButton ? .always : .never
		}
	}
	
	var floatingLabelAttributedText: NSAttributedString? {
		didSet {
			updateFloatingLabel()
		}
	}
		
	override var placeholder: String? {
		didSet {
			updatePlaceholderIfNeeded()
		}
	}
		
	override var attributedPlaceholder: NSAttributedString? {
		didSet {
			updateAttributedPlaceholderIfNeeded()
		}
	}
	
	override var text: String? {
		didSet {
			updateFloatingLabel()
		}
	}
	
	override var attributedText: NSAttributedString? {
		didSet {
			updateFloatingLabel()
		}
	}
		
	override func textRect(forBounds bounds: CGRect) -> CGRect {
		return updatePadding(for: bounds)
	}

	override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
		return updatePadding(for: bounds)
	}

	override func editingRect(forBounds bounds: CGRect) -> CGRect {
		return updatePadding(for: bounds)
	}
	
	private func updatePadding(for rect: CGRect) -> CGRect{
		let padding = UIEdgeInsets(
			top: Constants.defaultPadding.top,
			left: Constants.defaultPadding.left + floatingLabel.bounds.width + 8,
			bottom: Constants.defaultPadding.bottom,
			right: Constants.defaultPadding.right
		)

		return rect.inset(by: padding)
	}
	
	override var isEnabled: Bool {
		didSet {
			alpha = isEnabled ? 1 : 0.4
		}
	}
	
	private func updatePlaceholderIfNeeded() {
		if let placeholder = placeholder,
			!placeholder.isEmpty {
			placeholderText = placeholder
		}
	}
	
	private func updateAttributedPlaceholderIfNeeded() {
		if let attributedPlaceholder = attributedPlaceholder,
		   !attributedPlaceholder.string.isEmpty {
			attributedPlaceholderText = attributedPlaceholder
		}
	}
	
	required init(style: InputStylesBDUI) {
		self.style = style
		self.appearance = self.style.abandoned
		self.appearanceType = .abandoned
		
		super.init(frame: .zero)
		
		setupUI()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	private func setupUI() {
		autocorrectionType = .no // font color style switch fix
		
		translatesAutoresizingMaskIntoConstraints = false
		
		borderStyle = .none
		layer.cornerRadius = 10
		layer.masksToBounds = true
		
		layer.borderWidth = 1
		
		font = Style.Font.text
		
		floatingLabel.numberOfLines = 1
		
		addSubview(floatingLabel)
		
		rightButton.addTarget(self, action: #selector(rightButtonPressed), for: .touchDown)
		rightButton.contentEdgeInsets = insets(15)
		rightButton.imageEdgeInsets = insets(2)
		rightButton.tintColor = .Icons.iconPrimary
		rightView = rightButton
				
		height(56)
		floatingLabel.leadingToSuperview(offset: 15)
		
		floatingLabelCenterConstraint.isActive = true
				
		addTarget(self, action: #selector(handleEditing), for: .editingChanged)
		
		updateTheme()
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		
		let floatingLabelBaseLineOffset = ((floatingLabel.font?.ascender ?? 0) + (floatingLabel.font?.descender ?? 0)) * 0.5
		
		floatingLabelCenterConstraint.constant = -floatingLabelBaseLineOffset
	}
	
	@objc func rightButtonPressed() {
		isSecureTextEntry.toggle()
		
		let end = endOfDocument
		selectedTextRange = textRange(from: end, to: end)
		
		rightButton.setImage(
			isSecureTextEntry
				? .Icons.eye
				: .Icons.eyeCrossed,
			for: .normal
		)
	}
	
	@objc func handleEditing() {
		updateFloatingLabel()
	}
	
	private func updateFloatingLabel() {
		floatingLabel.attributedText = floatingLabelAttributedText
	}
	
	private func updateAppearance() {
		let currentInterfaceStyle = traitCollection.userInterfaceStyle
		
		layer.borderColor = appearance.borderColor?.color(for: currentInterfaceStyle)?.cgColor ?? UIColor.clear.cgColor
		textColor = appearance.fontColor?.color(for: currentInterfaceStyle)
	}
	
	private func isTextEmpty() -> Bool {
		return (text?.isEmpty ?? true) || (attributedText?.string.isEmpty ?? true)
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
	private var appearance: InputAppearanceBDUI {
		didSet {
			updateAppearance()
		}
	}
	
	var appearanceType: AppearanceTypeBDUI {
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
	
	private let style: InputStylesBDUI
	
	struct Constants {
		static let defaultPadding = UIEdgeInsets(top: 16, left: 15, bottom: 16, right: 15)
	}
}
