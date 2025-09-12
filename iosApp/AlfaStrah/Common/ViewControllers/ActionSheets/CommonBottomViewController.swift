//
//  CommonBottomViewController.swift
//  AlfaStrah
//
//  Created by vit on 31.01.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

import UIKit

class CommonBottomViewController: BaseBottomSheetViewController {
    struct Input {
        let title: String
        let placeholder: String
        let initialText: String?
        let keyboardType: UIKeyboardType
        let autocapitalizationType: UITextAutocapitalizationType
        let validationRules: [ValidationRule]
        let maxCharacterCount: CharsInputLimits
        let preventInputOnLimit: Bool
        var hideCounter: Bool = false
    }

    struct Output {
        let completion: (_ result: String) -> Void
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
            text: input.initialText ?? "",
            placeholder: input.placeholder,
            margins: Style.Margins.inputInsets,
            showSeparator: true,
            keyboardType: input.keyboardType,
            autocapitalizationType: input.autocapitalizationType,
            validationRules: input.validationRules,
            maxCharacterCount: input.maxCharacterCount,
            preventInputOnLimit: input.preventInputOnLimit
        )

        commonFieldView.textFieldDidBecomeActiveCallback = { [weak self] _ in
            guard let self = self
            else { return }
            
            if !self.input.hideCounter {
                self.set(charsCounter: self.charsCounter)
            }
            
            self.set(doneButtonEnabled: self.commonFieldView.isValid)
        }
        
        commonFieldView.textFieldChangedCallback = { [weak self] _ in
            guard let self = self
            else { return }
            
            self.commonFieldView.validate()
            
            if !self.input.hideCounter {
                self.set(charsCounter: self.charsCounter)
            }
            
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
        switch input.maxCharacterCount {
            case .limited(let maxChars):
                let numEnteredChars = commonFieldView.currentText?.count ?? 0

                if numEnteredChars > 0 {
                    return .enteredOutOfMax(
                        numEnteredChars: numEnteredChars,
                        maxChars: maxChars
                    )
                } else {
                    let numCharsLeft = maxChars - numEnteredChars
                    return .remaining(numLeftChars: numCharsLeft)
                }

            case .unlimited:
                return nil
        }
    }
}
