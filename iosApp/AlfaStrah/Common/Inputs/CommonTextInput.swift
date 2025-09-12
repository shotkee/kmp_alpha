//
//  CommonTextInput.swift
//  AlfaStrah
//
//  Created by vit on 29.08.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

class CommonTextInput: UIView {
    let textField = CommonTextField()
    let inputStatusLabel = UILabel()
    
    private lazy var textFieldBottomConstraint: NSLayoutConstraint = {
        return textField.bottomAnchor.constraint(equalTo: bottomAnchor)
    }()
    
    private lazy var inputStatusLabelConstraints: [NSLayoutConstraint] = [
        inputStatusLabel.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 6),
        inputStatusLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
        inputStatusLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
        inputStatusLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
    ]
    
    var validationRules: [ValidationRule] = []
    
    var shoudValidate = true
    var validateAsYouType = true
    var shouldShowValidateStateAsYouType = true
    
    var isValid = true
    
    var showErrorState = true
    
    private var isEditing = false
        
    private func validate() {
        isValid = true
        
        guard shoudValidate
        else { return }
        
        for rule in validationRules {
            switch rule.validate(textField.text ?? "") {
                case .success:
                    continue
                case .failure(let error):
                    inputStatusLabel.text = error.localizedDescription
                    isValid = false
                    return
            }
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
        addSubview(textField)
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(inputStatusLabel)
        inputStatusLabel.translatesAutoresizingMaskIntoConstraints = false
        inputStatusLabel.numberOfLines = 0
        inputStatusLabel <~ Style.Label.negativeSubhead
        
        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(equalTo: topAnchor),
            textField.leadingAnchor.constraint(equalTo: leadingAnchor),
            textField.trailingAnchor.constraint(equalTo: trailingAnchor),
            textFieldBottomConstraint
        ])
        
        textField.addTarget(self, action: #selector(textFieldEditingDidBegin), for: .editingDidBegin)
        textField.addTarget(self, action: #selector(textFieldEditingChanged), for: .editingChanged)
        textField.addTarget(self, action: #selector(textFieldEditingDidEnd), for: .editingDidEnd)
    }
    
    @objc func textFieldEditingDidBegin() {
        textField.appearance = .selected

        statusLabel(show: false)
        
        isEditing = true
    }
    
    @objc func textFieldEditingChanged() {
        if validateAsYouType {
            validate()
            if shouldShowValidateStateAsYouType {
                statusLabel(show: !isValid)
            }
        }
        
        updateTextFieldAppearance(isEditing: true, showErrorState: shouldShowValidateStateAsYouType && showErrorState)
    }
    
    @objc func textFieldEditingDidEnd() {
        forceValidate()
        
        isEditing = false
    }
    
    private func forceValidate() {
        validate()
        
        updateTextFieldAppearance(isEditing: false, showErrorState: showErrorState)
        
        if let text = textField.text,
           text.isEmpty {
            statusLabel(show: false)
        } else {
            statusLabel(show: !isValid)
        }
    }
    
    private func updateTextFieldAppearance(isEditing: Bool, showErrorState: Bool = true) {
        if let text = textField.text,
           !text.isEmpty {
            textField.appearance = isValid
                ? isEditing
                    ? .selected
                    : .abandoned
                : showErrorState
                    ?   (!validateAsYouType && isEditing)
                        ? .selected
                        : .error
                    : isEditing
                        ? textField.appearance
                        : .abandoned
        } else {
            textField.appearance = isValid
                ? .abandoned
                : showErrorState
                    ? isEditing
                        ? .error
                        : .abandoned
                    : .abandoned
        }
    }
    
    private func statusLabel(show: Bool) {
        if show {
            if showErrorState {
                inputStatusLabel.isHidden = false
                NSLayoutConstraint.deactivate([textFieldBottomConstraint])
                NSLayoutConstraint.activate(inputStatusLabelConstraints)
            }
        } else {
            inputStatusLabel.isHidden = true
            NSLayoutConstraint.deactivate(inputStatusLabelConstraints)
            NSLayoutConstraint.activate([textFieldBottomConstraint])
        }
    }
    
    func error(show: Bool, with text: String = "") {
        inputStatusLabel.text = text
        
        textField.appearance = show
            ? .error
            : isEditing
                ? .selected
                : .abandoned
        
        statusLabel(show: show)
    }
}
