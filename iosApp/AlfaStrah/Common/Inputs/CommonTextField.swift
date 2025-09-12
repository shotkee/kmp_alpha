//
//  CommonTextField.swift
//  AlfaStrah
//
//  Created by vit on 24.08.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

class CommonTextField: UITextField {
    private let floatingLabel = UILabel()
    private let securityButton = UIButton(type: .system)
	private let clearButton = UIButton(type: .system)
    
    private var placeholderText: String?
    private var attributedPlaceholderText: NSAttributedString?
	
	enum RightView {
		case securityButton
		case clearButton
	}
    
	var rightViewKind: RightView? {
        didSet {
			switch rightViewKind {
				case .securityButton:
					rightView = securityButton
					
				case .clearButton:
					rightView = clearButton
					
				case nil:
					rightView = nil
			}
			
            rightViewMode = rightViewKind != nil ? .always : .never
			
			updateRightView()
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
			updateRightView()
        }
    }
    
    override var attributedText: NSAttributedString? {
        didSet {
            updateFloatingLabel()
			updateRightView()
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
            floatingLabel.text = placeholder
        }
    }
    
    private func updateAttributedPlaceholderIfNeeded() {
        if let attributedPlaceholder = attributedPlaceholder,
           !attributedPlaceholder.string.isEmpty {
            attributedPlaceholderText = attributedPlaceholder
            floatingLabel.attributedText = attributedPlaceholder
        }
    }

    var appearance: Appearance = .abandoned {
        didSet {
            updateAppearance()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        autocorrectionType = .no // font color style switch fix
        
        translatesAutoresizingMaskIntoConstraints = false
        
        backgroundColor = .Background.fieldBackground
        borderStyle = .none
        layer.cornerRadius = 10
        layer.masksToBounds = true
        
        layer.borderWidth = 1
        
        font = Style.Font.text
        
        floatingLabel.translatesAutoresizingMaskIntoConstraints = false
        floatingLabel <~ Style.Label.secondaryCaption2
        floatingLabel.numberOfLines = 1
        
        addSubview(floatingLabel)
        
        updateAppearance()
        
        securityButton.setImage(.Icons.eyeCrossed, for: .normal)
        securityButton.addTarget(self, action: #selector(secureButtonPressed), for: .touchDown)
        securityButton.contentEdgeInsets = insets(15)
        securityButton.imageEdgeInsets = insets(2)
        securityButton.tintColor = .Icons.iconPrimary
		
		clearButton.setImage(.Icons.deleteSmall, for: .normal)
		clearButton.tintColor = .Icons.iconMedium
		clearButton.addTarget(self, action: #selector(clearButtonPressed), for: .touchUpInside)
		clearButton.contentEdgeInsets = insets(15)
		clearButton.tintColor = .Icons.iconPrimary
		
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 56),
            floatingLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),
            floatingLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 15),
            floatingLabel.topAnchor.constraint(equalTo: topAnchor, constant: 11),
            floatingLabel.heightAnchor.constraint(equalToConstant: 15)
        ])
        
        updateFloatingLabel()
		updateRightView()
        
        addTarget(self, action: #selector(handleEditing), for: .editingChanged)
    }
    
    @objc func secureButtonPressed() {
        isSecureTextEntry.toggle()
        
        let end = endOfDocument
        selectedTextRange = textRange(from: end, to: end)
        
        securityButton.setImage(
            isSecureTextEntry
                ? .Icons.eye
                : .Icons.eyeCrossed,
            for: .normal
        )
    }
	
	@objc func clearButtonPressed() {
		text = nil
		sendActions(for: .editingChanged)
	}
    
    @objc func handleEditing() {
        updateFloatingLabel()
		updateRightView()
    }
    
    private func updateFloatingLabel() {
        floatingLabel.isHidden = isTextEmpty()
    }
	
	private func updateRightView() {
		switch rightViewKind {
			case .clearButton:
				rightView?.isHidden = isTextEmpty()
			case .securityButton, .none:
				break
		}
	}
    
    private func updateAppearance() {
        layer.borderColor = appearance.borderColor.cgColor
        textColor = appearance.fontColor
    }

    private func isTextEmpty() -> Bool {
        return text?.isEmpty
            ?? attributedText?.string.isEmpty
            ?? true
    }
    
    // MARK: - Appearance
    struct Appearance {
        let borderColor: UIColor
        let fontColor: UIColor
                                        
        static var abandoned: Appearance = Appearance(
			borderColor: .clear,
            fontColor: .Text.textPrimary
        )
        
        static var selected: Appearance = Appearance(
            borderColor: .Stroke.strokeInput,
            fontColor: .Text.textPrimary
        )
        
        static var error: Appearance = Appearance(
            borderColor: .Stroke.strokeNegative,
            fontColor: .Text.textPrimary
        )
    }
	
	// MARK: - Dark Theme Support
	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
		
		updateAppearance()
	}
    
    struct Constants {
        static let paddingText = UIEdgeInsets(top: 24, left: 15, bottom: 10, right: 15)
        static let paddingPlaceholderText = UIEdgeInsets(top: 16, left: 15, bottom: 16, right: 15)
    }
}
