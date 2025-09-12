//
//  AccountInputBottomViewController.swift
//  AlfaStrah
//
//  Created by Nikita Omelchenko on 25.01.2021.
//  Copyright © 2021 Redmadrobot. All rights reserved.
//

import UIKit

class AccountInputBottomViewController: BaseBottomSheetViewController {
    private let maximumCharsCount = 20
    private lazy var textInputView: CommonAccountNumberView = {
        let value: CommonAccountNumberView = .init(frame: .zero)
        value.heightAnchor.constraint(equalToConstant: 54).isActive = true

        return value
    }()

    struct Input {
        let accountNumber: String?
        let validationRules: [ValidationRule]
        let contentMask: String?
    }

    struct Output {
        let close: () -> Void
        let number: (String) -> Void
    }

    var input: Input!
    var output: Output!

    override func viewDidLoad() {
        super.viewDidLoad()

        closeTapHandler = output.close
        primaryTapHandler = { [unowned self] in
            guard self.textInputView.isValid else { return }

            self.output.number(textInputView.accountNumber)
        }
    }

    override func setupUI() {
        super.setupUI()

        set(title: NSLocalizedString("accident_person_account_number_long_title", comment: ""))
        
        let text = NSLocalizedString("accident_person_account_number_text", comment: "")
        
        let descriptionWithColor = NSMutableAttributedString(
            string: text
        )
                
        set(attributedInfoText: descriptionWithColor)
        set(views: [ textInputView ])

        textInputView.set(
            maximumCharsCount: maximumCharsCount,
            accountNumber: input.accountNumber ?? "",
            validationRules: input.validationRules,
            contentMask: input.contentMask
        )

        textInputView.textFieldChangedCallback = { [unowned self] _ in
            self.set(doneButtonEnabled: self.textInputView.isValid)
        }

        textInputView.textFieldDidBecomeActiveCallback = { [unowned self] _ in
            self.set(doneButtonEnabled: self.textInputView.isValid)
        }

        animationWhileTransition = { [weak self] in
            self?.textInputView.becomeActive()
        }
    }
}
