//
//  PhoneInputBottomViewController.swift
//  AlfaStrah
//
//  Created by Shukhrat Sagatov on 14.10.2021.
//  Copyright © 2021 Redmadrobot. All rights reserved.
//

import UIKit

class PhoneInputBottomViewController: BaseBottomSheetViewController {
    struct Input {
        let title: String
        let placeholder: String
        let initialPhoneText: String?
        
        init(
            title: String,
            placeholder: String,
            initialPhoneText: String?
        ) {
            self.title = title
            self.placeholder = placeholder
            self.initialPhoneText = initialPhoneText
        }
    }

    struct Output {
        let completion: (_ phone: String, _ humanReadable: String) -> Void
    }

    var input: Input!
    var output: Output!

    private var phoneInput: FancyTextInput = FancyTextInput()

    private lazy var textFieldController: TextFieldController = TextFieldController(
        textField: self.phoneInput.textField,
        asYouTypeFormatter: PhoneNumberFormatter(predefinedAreaCode: 7, maxNumberLength: 10)
    )

    override func viewDidLoad() {
        super.viewDidLoad()

        closeTapHandler = { [unowned self] in
            self.dismiss(animated: true, completion: nil)
        }
        primaryTapHandler = { [unowned self] in
            self.output.completion(
                "+7" + textFieldController.unformattedString,
                textFieldController.formattedString(from: textFieldController.unformattedString)
            )
        }

        updateUI(
            isInputValid: !(input.initialPhoneText?.isEmpty ?? true)
        )

        textFieldController.onTextDidChange = { [unowned self] _ in
            let isInputValid = self.textFieldController.unformattedString.count == 10
            self.updateUI(isInputValid: isInputValid)
        }
        animationWhileTransition = { [unowned self] in
            self.phoneInput.becomeFirstResponder()
        }
    }

    override func setupUI() {
        super.setupUI()

        set(title: input.title)
        set(views: [ phoneInput ])
        phoneInput.set(textFieldController: textFieldController)
        phoneInput.textFieldPlaceholderText = input.placeholder
        phoneInput.textField.keyboardType = .numberPad
        phoneInput.updateTextField(text: input.initialPhoneText ?? "")
        phoneInput.descriptionCopiesPlaceholder = false
        phoneInput.isLineSeparatorVisible = true
    }

    private func updateUI(isInputValid: Bool)
    {
        self.phoneInput.isRightIconVisible = isInputValid
        self.set(doneButtonEnabled: isInputValid)
    }
}
