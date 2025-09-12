//
//  FloatingTitleTextFieldView.swift
//  AlfaStrah
//
//  Created by vit on 19.11.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

class FloatingTitleTextFieldView: UITextField, TextInputBDUI {
	private let floatingLabel = UILabel()
	private let rightButton = UIButton(type: .system)
	
	private var placeholderText: String?
	private var attributedPlaceholderText: NSAttributedString?

	enum RightView {
		case securityButton
		case clearButton
		case arrowRightButton
	}
	
	var rightViewKind: RightView? {
		didSet {
			switch rightViewKind {
				case .securityButton:
					rightView = rightButton
					rightButton.setImage(.Icons.eyeCrossed, for: .normal)
					rightButton.tintColor = .Icons.iconPrimary
					rightButton.contentEdgeInsets = insets(15)
					rightButton.imageEdgeInsets = insets(2)
					
				case .clearButton:
					rightView = rightButton
					rightButton.setImage(.Icons.deleteSmall, for: .normal)
					rightButton.tintColor = .Icons.iconMedium
					rightButton.contentEdgeInsets = insets(15)
					
				case .arrowRightButton:
					rightView = rightButton
					rightButton.setImage(.Icons.chevronSmallRight, for: .normal)
					rightButton.contentEdgeInsets = insets(15)
					rightButton.tintColor = style.accessoryThemedColor?.color(for: traitCollection.userInterfaceStyle) ?? .Icons.iconMedium
					
				case nil:
					rightView = nil
					
			}
			
			rightViewMode = rightViewKind != nil ? .always : .never
		}
	}
		
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
		return bounds.inset(by: Constants.paddingPlaceholderText)
	}

	override func editingRect(forBounds bounds: CGRect) -> CGRect {
		return updatePadding(for: bounds)
	}
	
	private func updatePadding(for rect: CGRect) -> CGRect{
		let padding = isTextEmpty()
			? Constants.paddingPlaceholderText
			: Constants.paddingText

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
		
		floatingLabel.translatesAutoresizingMaskIntoConstraints = false
		floatingLabel.numberOfLines = 1
		
		addSubview(floatingLabel)
				
		rightButton.addTarget(self, action: #selector(rightButtonPressed), for: .touchDown)

		NSLayoutConstraint.activate([
			heightAnchor.constraint(equalToConstant: 56),
			floatingLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),
			floatingLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 15),
			floatingLabel.topAnchor.constraint(equalTo: topAnchor, constant: 11),
			floatingLabel.heightAnchor.constraint(equalToConstant: 15)
		])
				
		addTarget(self, action: #selector(handleEditing), for: .editingChanged)
		
		updateTheme()
	}
	
	private func secureButtonPressed() {
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
	
	private func clearButtonPressed() {
		text = nil
		sendActions(for: .editingChanged)
	}
	
	@objc func rightButtonPressed() {
		switch rightViewKind {
			case .arrowRightButton:
				break
			case .clearButton:
				clearButtonPressed()
				
			case .securityButton:
				secureButtonPressed()
				
			default:
				break
		}
	}
	
	@objc func handleEditing() {
		updateFloatingLabel()
	}
	
	private func updateFloatingLabel() {
		floatingLabel.attributedText = floatingLabelAttributedText
		floatingLabel.isHidden = isTextEmpty()
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
		static let paddingText = UIEdgeInsets(top: 24, left: 15, bottom: 10, right: 15)
		static let paddingPlaceholderText = UIEdgeInsets(top: 16, left: 15, bottom: 16, right: 15)
	}
}
