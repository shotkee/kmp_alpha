//
//  PhoneView.swift
//  AlfaStrah
//
//  Created by Evgeny Ivanov on 24/12/2018.
//  Copyright © 2018 Redmadrobot. All rights reserved.
//

import UIKit

final class PhoneView: UIView {
    var phone: String = ""

    var plainPhone: String {
        textFieldController.unformattedString
    }

    var keyboardAccessoryView: UIView? {
        get {
            phoneInput.textField.inputAccessoryView
        }
        set {
            phoneInput.textField.inputAccessoryView = newValue
        }
    }

    var onTextDidChange: TextFieldController.TextFieldActionCallback? {
        get {
            textFieldController.onTextDidChange
        }
        set {
            textFieldController.onTextDidChange = newValue
        }
    }

    override var isFirstResponder: Bool {
        phoneInput.textField.isFirstResponder
    }

    private (set) var phoneInput: FancyTextInput = FancyTextInput()

    private lazy var textFieldController: TextFieldController = TextFieldController(
        textField: self.phoneInput.textField,
        asYouTypeFormatter: PhoneNumberFormatter(predefinedAreaCode: 7, maxNumberLength: 10)
    )

    override init(frame: CGRect) {
        super.init(frame: frame)

        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        setup()
    }

    @objc func updatePhone(number: String) {
        phoneInput.updateTextField(text: number)
    }

    private func setup() {
        let separator = HairLineView()
		separator.lineColor = .Stroke.divider
        separator.translatesAutoresizingMaskIntoConstraints = false
        addSubview(separator)

        phoneInput.set(textFieldController: textFieldController)
        phoneInput.translatesAutoresizingMaskIntoConstraints = false
        phoneInput.textFieldPlaceholderText = NSLocalizedString("auth_sign_up_phone", comment: "")
        phoneInput.descriptionText = NSLocalizedString("auth_sign_up_phone", comment: "")
        phoneInput.descriptionCopiesPlaceholder = true
        phoneInput.textField.keyboardType = .numberPad
        addSubview(phoneInput)

        NSLayoutConstraint.activate([
            phoneInput.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            phoneInput.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            phoneInput.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            phoneInput.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),
            phoneInput.heightAnchor.constraint(equalToConstant: 40),

            separator.leadingAnchor.constraint(equalTo: phoneInput.leadingAnchor),
            separator.trailingAnchor.constraint(equalTo: trailingAnchor),
            separator.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0),
            separator.heightAnchor.constraint(equalToConstant: 1),
        ])
    }
}
