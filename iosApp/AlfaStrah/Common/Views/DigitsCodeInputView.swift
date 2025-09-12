//
//  DigitsCodeInputView.swift
//  AlfaStrah
//
//  Created by vit on 17.03.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

class DigitsCodeInputView: UIView, UITextFieldDelegate {
    private var appearance: Appearance = .active {
        didSet {
			if appearance != oldValue {
				updateFieldsAppearance()
			}
        }
    }
    
    struct Output {
        var codeEntered: (String) -> Void
        var onEditingChanged: () -> Void
    }
            
    var output: Output!
    
    private let containerStackView = UIStackView()
    private var fields: [UITextField] = []
	private let length: Int

    required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
    }
	
	init(
		frame: CGRect,
		length: Int
	)
	{
		self.length = length
		super.init(frame: frame)
		setup()
	}
    
    private func setup() {
        setupContentStackView()
        addFields()
    }
    
    private func setupContentStackView() {
        self.addSubview(containerStackView)
        
        containerStackView.isLayoutMarginsRelativeArrangement = true
        containerStackView.layoutMargins = UIEdgeInsets(top: 0, left: 18, bottom: 0, right: 18)
        containerStackView.alignment = .fill
        containerStackView.distribution = .fillEqually
        containerStackView.axis = .horizontal
        containerStackView.spacing = Constants.fieldsSpacing
        containerStackView.backgroundColor = .clear
        
        containerStackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate(
            NSLayoutConstraint.fill(view: containerStackView, in: self)
        )
    }
    
    private func addFields() {
        containerStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        for _ in 1...length {
            containerStackView.addArrangedSubview(createField())
        }
        
        updateFieldsAppearance()
    }
    
    private func createField() -> UITextField {
        let textField = UITextField()
        textField.textAlignment = .center
        textField.layer.borderWidth = 1
        textField.isOpaque = false
        textField.font = Constants.font
        textField.layer.cornerRadius = Constants.cornerRadius
        textField.autocapitalizationType = .none
        textField.keyboardType = .numberPad
        textField.autocorrectionType = .no
        textField.tintColor = .clear
        
        textField.isUserInteractionEnabled = false
        
        textField.textContentType = .oneTimeCode
        
        textField.delegate = self
        
        fields.append(textField)
        
        return textField
    }
    
    private func updateFieldsAppearance() {
        for field in containerStackView.subviews {
            if let textField = field as? UITextField {
				updateAppearance(textField)
            }
        }
    }
        
    func becomeActive() {
        containerStackView.subviews.first?.isUserInteractionEnabled = true
        containerStackView.subviews.first?.becomeFirstResponder()
    }

    func clear() {
        appearance = .active

        for textField in fields {
            textField.text = ""
            textField.isUserInteractionEnabled = false
        }
        
        containerStackView.subviews.first?.isUserInteractionEnabled = true
        containerStackView.subviews.first?.becomeFirstResponder()
    }
    
    func setFocus() {
        containerStackView.subviews.last?.isUserInteractionEnabled = true
        containerStackView.subviews.last?.becomeFirstResponder()
    }
    
    func error() {
        alpha = 1
        appearance = .error
        containerStackView.subviews.last?.isUserInteractionEnabled = true
        containerStackView.subviews.last?.becomeFirstResponder()
        
        UIView.animate(
            withDuration: 0.5,
            delay: 0,
            usingSpringWithDamping: 0.3,
            initialSpringVelocity: 30,
            options: .curveEaseIn,
            animations: { [weak self] in
                guard let self = self
                else { return }
                
                self.frame.origin.x += self.frame.width / 4
            }
        )
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        output.onEditingChanged()
       
        return handleOtp(
            textField,
            replacementString: string
        ) { [weak self] code in
            self?.output.codeEntered(code)
        }
    }
    
    private func handleOtp(
        _ textField: UITextField,
        replacementString string: String,
        _ completion: @escaping (String) -> Void
    ) -> Bool {
        guard let index = containerStackView.arrangedSubviews.firstIndex(of: textField),
              let text = textField.text
        else { return true }
                        
        if string.isEmpty {
            if !text.isEmpty {
                textField.text = ""
                if let previousTextField = fields[safe: index - 1] { // current field will be cleared, focus will be set on previous
                    appearance = .active
                    previousTextField.isUserInteractionEnabled = true
                    previousTextField.becomeFirstResponder()
                    textField.isUserInteractionEnabled = false
                }
                return false
            }
        } else {
            if text.isEmpty {
                if index == 0 { // first field will be filled, focus will be set on current
                    return true
                }
            } else {
                if let nextTextField = fields[safe: index + 1] {
                    nextTextField.text = string
                    setFocusTextField(
                        textField: textField,
                        nextTextField: nextTextField,
                        string: string,
                        completion
                    )
                    return false
                }
                else if appearance == .error {
                    appearance = .active
                    fields.forEach { textField in
                        textField.text = nil
                    }
                    
                    let firstTextField = fields[0]
                    firstTextField.text = string
                    let nextTextField = fields[1]
                    
                    setFocusTextField(
                        textField: textField,
                        nextTextField: nextTextField,
                        string: "",
                        completion
                    )
                }
            }
        }
        
        return text.isEmpty ? true : false
    }
    
    private func setFocusTextField(
        textField: UITextField,
        nextTextField: UITextField,
        string: String,
        _ completion: @escaping (String) -> Void
    ) {
        if codeEntered(currentTextField: textField, string: string) {   // last field will be filled, focus will be removed
            textField.isUserInteractionEnabled = false
            alpha = 0.4
            completion(readCode())
        } else {    // current field will be filled, focus will be set on next
            nextTextField.isUserInteractionEnabled = true
            nextTextField.becomeFirstResponder()
            textField.isUserInteractionEnabled = false
        }
    }
        
    func textFieldDidChangeSelection(_ textField: UITextField) {
        let position = textField.endOfDocument
        textField.selectedTextRange = textField.textRange(from: position, to: position)
    }
    
    private func codeEntered(currentTextField: UITextField, string: String) -> Bool {
        for field in containerStackView.subviews {
            if let textField = field as? UITextField,
               let text = textField.text {
                if text.isEmpty{
                    if currentTextField == textField && !string.isEmpty {
                        continue
                    }
                    return false
                }
            }
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        alpha = 1
		
		updateAppearance(textField)
    }
   
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.layer.borderColor = appearance.borderColor.cgColor
    }
	
	private func updateAppearance(_ textField: UITextField) {
		switch appearance {
			case .active:
				textField <~ Appearance.active
			case .error:
				textField <~ Appearance.error
			default:
				textField <~ Appearance.active
		}
	}
    
    private func readCode() -> String {
        var code: String = ""
        for field in fields {
            if let text = field.text {
                code += text
            }
        }
        return code
    }
	
	// MARK: - Dark Theme Support
	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
		
		updateFieldsAppearance()
	}
	
    struct Constants {
        static let fieldsSpacing: CGFloat = 9
        static let cornerRadius: CGFloat = 10
        static let font: UIFont = Style.Font.title1
    }
    
    // MARK: - Appearance
	struct Appearance: Equatable, Applicable {
        let borderColor: UIColor
        let borderColorSelected: UIColor
        let fontColor: UIColor
        let backgroundColor: UIColor
		
		func apply(_ object: UITextField) {
			object.backgroundColor = backgroundColor
			object.layer.borderColor = object.isEditing ? borderColorSelected.cgColor : borderColor.cgColor
			object.textColor = fontColor
		}
        
        static let active: Appearance = Appearance(
            borderColor: .clear,
			borderColorSelected: .Stroke.strokeInput,
			fontColor: .Text.textPrimary,
			backgroundColor: .Background.fieldBackground
        )
        
        static let error: Appearance = Appearance(
            borderColor: .clear,
			borderColorSelected: .Stroke.strokeNegative,
			fontColor: .Text.textNegative,
			backgroundColor: .Background.backgroundNegativeTint
        )
    }
}
