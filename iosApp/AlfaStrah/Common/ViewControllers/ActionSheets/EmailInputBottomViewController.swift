//
//  EmailInputBottomViewController.swift
//  AlfaStrah
//
//  Created by Vyacheslav Shakaev on 17.06.2022.
//  Copyright © 2022 Touch Instinct. All rights reserved.
//

import UIKit

class EmailInputBottomViewController: BaseBottomSheetViewController {
    struct Input {
        let title: String
        let placeholder: String
        let initialEmailText: String?
    }

    struct Output {
        let completion: (_ email: String) -> Void
    }

    var input: Input!
    var output: Output!

    private let commonFieldView = CommonFieldView()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }

    private func setup() {
        set(title: input.title)
        set(views: [ commonFieldView ])
                
        commonFieldView.set(
            text: input.initialEmailText ?? "",
            placeholder: input.placeholder,
            margins: Style.Margins.inputInsets,
            showSeparator: true,
            keyboardType: .emailAddress,
            autocapitalizationType: .none,
            validationRules: [
                EmailValidationRule(),
                LengthValidationRule(maxChars: Constants.charsLimited.value)
            ],
            maxCharacterCount: Constants.charsLimited
        )

        commonFieldView.textFieldDidBecomeActiveCallback = { [weak self] _ in
            guard let self = self
            else { return }
            
            self.set(charsCounter: self.charsCounter)
            self.set(doneButtonEnabled: self.commonFieldView.isValid)
        }
        
        commonFieldView.textFieldChangedCallback = { [weak self] _ in
            guard let self = self
            else { return }
            
            self.commonFieldView.validate()
            self.set(charsCounter: self.charsCounter)
            self.set(doneButtonEnabled: self.commonFieldView.isValid)
        }
        
        closeTapHandler = { [weak self] in
            self?.dismiss(animated: true)
        }
        
        primaryTapHandler = { [weak self] in
            guard let self = self else { return }

            self.output.completion(
                self.commonFieldView.currentText ?? ""
            )
        }
        
        animationWhileTransition = { [weak self] in
            self?.commonFieldView.becomeActive()
        }
    }
    
    private var charsCounter: CharsCounter? {
        let numEnteredChars = commonFieldView.currentText?.count ?? 0

        if numEnteredChars > 0 {
            return .enteredOutOfMax(
                numEnteredChars: numEnteredChars,
                maxChars: Constants.charsLimited.value
            )
        } else {
            let numCharsLeft = Constants.charsLimited.value - numEnteredChars
            return .remaining(numLeftChars: numCharsLeft)
        }
    }
    
    struct Constants {
        static let charsLimited: CharsInputLimits = .limited(120)
    }
}
