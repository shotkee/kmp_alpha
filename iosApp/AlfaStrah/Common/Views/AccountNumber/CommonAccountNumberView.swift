//
//  CommonAccountNumberView.swift
//  AlfaStrah
//
//  Created by Nikita Omelchenko on 26.01.2021.
//  Copyright © 2021 Redmadrobot. All rights reserved.
//

import UIKit
import InputMask

class CommonAccountNumberView: UIView, MaskedTextFieldDelegateListener {
    @IBOutlet private var listener: MaskedTextFieldDelegate!
    @IBOutlet private var rootStackView: UIStackView!
    @IBOutlet private var numberTextField: UITextField!

    private var maximumCharsCount: Int = 0
    private var inputAccountNumber: String = ""
    private var contentMask: String?

    private let defaultBorderColor = Style.Color.Palette.whiteGray

    var textFieldChangedCallback: ((UITextField) -> Void)?
    var textFieldDidBecomeActiveCallback: ((UITextField) -> Void)?

    var accountNumber: String {
        currentText
    }

    var currentNoteTextCount: Int {
        maximumCharsCount - currentText.count
    }

    private var currentText: String = ""

    override var isFirstResponder: Bool {
        numberTextField.isFirstResponder
    }

    func becomeActive() {
        if numberTextField.canBecomeFirstResponder {
            numberTextField.becomeFirstResponder()
        }
    }

    // MARK: Init

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        commonSetup()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        commonSetup()
    }

    func set(
        maximumCharsCount: Int,
        accountNumber: String,
        validationRules: [ValidationRule] = [],
        contentMask: String? = nil
    ) {
        self.maximumCharsCount = maximumCharsCount
        self.inputAccountNumber = accountNumber
        self.validationRules = validationRules
        self.contentMask = contentMask

        updateUI()
    }

    private func updateUI() {
        if let mask = contentMask {
            listener.primaryMaskFormat = mask
        }
        
        listener.put(
            text: inputAccountNumber,
            into: numberTextField
        )
    }

    private func commonSetup() {
        addSelfAsSubviewFromNib()
        setup()
    }

    private func setup() {
        numberTextField.font = Style.Font.title1
		backgroundColor = .Background.backgroundSecondary
		numberTextField.textColor = .Text.textPrimary

        layer.cornerRadius = 7
        layer.masksToBounds = true
        layer.borderWidth = 1
        layer.borderColor = defaultBorderColor.cgColor
    }

    func textField(_ textField: UITextField, didFillMandatoryCharacters complete: Bool, didExtractValue value: String) {
        currentText = value
        textFieldChangedCallback?(textField)
    }

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        textFieldDidBecomeActiveCallback?(textField)
        return true
    }

    // MARK: - Validation

    private var validationRules: [ValidationRule] = []

    private var shoudValidate: Bool {
        !validationRules.isEmpty
    }

    var isValid: Bool {
        guard shoudValidate else { return true }

        var isValid = true

        mainLoop: for rule in validationRules {
            switch rule.validate(currentText) {
                case .success:
                    continue
                case .failure:
                    isValid = false
                    break mainLoop
            }
        }

        return isValid
    }
}
