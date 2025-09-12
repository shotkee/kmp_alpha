//
//  TextAreaInputViewController.swift
//  AlfaStrah
//
//  Created by Shukhrat Sagatov on 06.08.2021.
//  Copyright © 2021 Redmadrobot. All rights reserved.
//

import UIKit
import Legacy

class TextAreaInputBottomViewController: BaseBottomSheetViewController {
    struct Input {
        let title: String
        let description: String?
        let textInputTitle: String?
        let textInputPlaceholder: String
        let initialText: String?
        let validationRules: [ValidationRule]
        let showValidInputIcon: Bool
        let keyboardType: UIKeyboardType
        let autocapitalizationType: UITextAutocapitalizationType
        let charsLimited: CharsInputLimits
        let showMaxCharsLimit: Bool
    }

    struct Output {
        let close: () -> Void
        let text: (String) -> Void
    }

    var output: Output!
    var input: Input!

    private lazy var textInputView: TextAreaInputField = .init(frame: .zero)

    override func viewDidLoad() {
        super.viewDidLoad()

        closeTapHandler = output.close
        primaryTapHandler = { [unowned self] in
            guard self.textInputView.isValid else { return }

            self.output.text(textInputView.currentText ?? "")
        }
    }

    override func setupUI() {
        super.setupUI()

        set(title: input.title)
        set(infoText: input.description ?? "")
        set(views: [ textInputView ])

        textInputView.set(
            title: input.textInputTitle,
            note: input.initialText ?? "",
            placeholder: input.textInputPlaceholder,
            showSeparator: false,
            keyboardType: input.keyboardType,
            autocapitalizationType: input.autocapitalizationType,
            validationRules: input.validationRules,
            showValidInputIcon: input.showValidInputIcon,
            maxCharacterCount: input.charsLimited
        )

        textInputView.textViewDidBecomeActiveCallback = { [weak self] _ in
            guard let self = self
            else { return }
            
            self.set(charsCounter: self.charsCounter)
            self.set(doneButtonEnabled: self.textInputView.isValid)
        }

        textInputView.textViewChangedCallback = { [weak self] _ in
            guard let self = self
            else { return }
            self.textInputView.validate()
            self.set(charsCounter: self.charsCounter)
            self.set(doneButtonEnabled: self.textInputView.isValid)
        }

        animationWhileTransition = { [weak self] in
            self?.textInputView.becomeActive()
        }
    }

    private var charsCounter: CharsCounter?
    {
        switch input.charsLimited
        {
            case .limited(let maxChars):
                let numEnteredChars = textInputView.numEnteredChars

                if input.showMaxCharsLimit && numEnteredChars > 0
                {
                    return .enteredOutOfMax(
                        numEnteredChars: numEnteredChars,
                        maxChars: maxChars
                    )
                }
                else
                {
                    let numCharsLeft = maxChars - numEnteredChars
                    return .remaining(numLeftChars: numCharsLeft)
                }

            case .unlimited:
                return nil
        }
    }
}
