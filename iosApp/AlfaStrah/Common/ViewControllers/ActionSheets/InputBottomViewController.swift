//
//  InputBottomViewController.swift
//  AlfaStrah
//
//  Created by Nikita Omelchenko on 15.04.2021.
//  Copyright © 2021 Redmadrobot. All rights reserved.
//

class InputBottomViewController: BaseBottomSheetViewController {
    struct InputObject {
        let id: String = UUID().uuidString
        let text: String?
        let placeholder: String?
        var charsLimited: CharsInputLimits = .unlimited
        var keyboardType: UIKeyboardType = .default
        var autocapitalizationType: UITextAutocapitalizationType = .none
        var validationRule: [ValidationRule] = []
        var preventInputOnLimit: Bool = false
    }

    struct Input {
        let title: String?
        let infoText: String?
        let inputs: [InputObject]
    }

    struct Output {
        let close: () -> Void
        let done: (_ result: [String: String]) -> Void
    }

    var output: Output!
    var input: Input!

    private var inputViews: [String: CommonFieldView] = [:]

    override func viewDidLoad() {
        super.viewDidLoad()

        closeTapHandler = output.close
        primaryTapHandler = { [unowned self] in
            guard self.isValid else { return }

            self.output.done(inputViews.mapValues { $0.currentText ?? "" })
        }
    }

    var isValid: Bool {
        inputViews.values.allSatisfy { $0.isValid }
    }

    override func setupUI() {
        super.setupUI()

        set(title: input.title ?? "")
        set(infoText: input.infoText ?? "")
        
        input.inputs.forEach { input in
            createInputView(for: input)
        }
        set(doneButtonEnabled: self.isValid)

        animationWhileTransition = { [unowned self] in
            guard let id = self.input.inputs.first?.id else { return }

            inputViews[id]?.becomeActive()
        }
    }
    
    private func createInputView(for input: InputObject) {
        let inputView: CommonFieldView = .init(frame: .zero)
        inputView.set(
            text: input.text ?? "",
            placeholder: input.placeholder ?? "",
            margins: Style.Margins.inputInsets,
            showSeparator: true,
            keyboardType: input.keyboardType,
            autocapitalizationType: input.autocapitalizationType,
            validationRules: input.validationRule,
            maxCharacterCount: input.charsLimited,
            preventInputOnLimit: input.preventInputOnLimit
        )
        
        inputView.textFieldDidBecomeActiveCallback = { [unowned self, unowned inputView] _ in
            self.set(
                charsCounter: self.charsCounter(
                    for: input,
                    inputView: inputView
                )
            )
            self.set(doneButtonEnabled: inputView.isValid)
        }
        
        inputView.textFieldChangedCallback = { [unowned self, unowned inputView] _ in
            inputView.validate()
            self.set(
                charsCounter: self.charsCounter(
                    for: input,
                    inputView: inputView
                )
            )
            self.set(doneButtonEnabled: self.isValid)
        }
        
        inputViews[input.id] = inputView
        add(view: inputView)
    }
    
    private func charsCounter(
        for input: InputObject,
        inputView: CommonFieldView
    ) -> CharsCounter?
    {
        switch input.charsLimited
        {
            case .limited(let maxChars):
                let numEnteredChars = inputView.currentText?.count ?? 0
                return .enteredOutOfMax(
                    numEnteredChars: numEnteredChars,
                    maxChars: maxChars
                )
                
            case .unlimited:
                return nil
        }
    }
}
