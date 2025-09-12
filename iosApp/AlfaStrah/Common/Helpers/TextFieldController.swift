//
//  TextFieldController.swift
//  AlfaStrah
//
//  Created by Stanislav Starzhevskiy on 23.08.17.
//  Copyright © 2017 RedMadRobot. All rights reserved.
//

import UIKit

final class TextFieldController: NSObject, UITextFieldDelegate {
    typealias TextFieldActionCallback = (_ textField: UITextField) -> Void

    var onEditingDidBegin: TextFieldActionCallback?
    var onEditingDidEnd: TextFieldActionCallback?
    var onReturnPressed: TextFieldActionCallback?
    var onTextDidChange: TextFieldActionCallback?

    private var textField: UITextField?
    private var textEditingResult = FormatResult(string: "", caretPosition: .end)
    private var asYouTypeFormatter: AsYouTypeFormatter?

    @objc func formattedString(from input: String) -> String {
        guard let formatter = asYouTypeFormatter else { return input }

        let result = formatter.format(existing: input, input: input, range: NSRange(location: 0, length: input.count))
        return result.string
    }

    var unformattedString: String {
        unformattedString(from: textField?.text ?? "")
    }

    @objc func unformattedString(from input: String) -> String {
        guard let formatter = asYouTypeFormatter else { return input }

        let result = formatter.unformatted(input)
        return result
    }

    init(textField: UITextField?, asYouTypeFormatter: AsYouTypeFormatter?) {
        self.textField = textField
        self.asYouTypeFormatter = asYouTypeFormatter
        super.init()

        textField?.delegate = self
        textField?.addTarget(self, action: #selector(textFieldEditingChanged(_:)), for: .editingChanged)
    }

    /// objc doesn't understands Int? so -1 will be the substitution
    @objc convenience init(textField: UITextField, countryCode: Int, maxNumberLength: Int) {
        let code: Int? = (countryCode == -1) ? nil : countryCode
        let length: Int? = (maxNumberLength == -1) ? 15 : maxNumberLength

        self.init(textField: textField, asYouTypeFormatter: PhoneNumberFormatter(predefinedAreaCode: code, maxNumberLength: length))
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        onEditingDidEnd?(textField)
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        onEditingDidBegin?(textField)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        onReturnPressed?(textField)
        return true
    }

    @objc private func textFieldEditingChanged(_ textField: UITextField) {
        guard asYouTypeFormatter == nil else { return }

        textField.text = textEditingResult.string
        textField.selectedTextRange = textEditingResult.selectedTextRange(in: textField)
        onTextDidChange?(textField)
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let asYouTypeFormatter = asYouTypeFormatter {
            textEditingResult = asYouTypeFormatter.format(existing: textField.text ?? "", input: string, range: range)
            textField.text = textEditingResult.string
            textField.selectedTextRange = textEditingResult.selectedTextRange(in: textField)
            textField.sendActions(for: .editingChanged)
            onTextDidChange?(textField)
            return false
        }
        return true
    }
}

extension FormatResult {
    func selectedTextRange(in textField: UITextField) -> UITextRange? {
        switch caretPosition {
            case .end:
                return textField.textRange(from: textField.endOfDocument, to: textField.endOfDocument)
            case .position(let pos):
                guard let tpos = textField.position(from: textField.beginningOfDocument, offset: pos) else { return nil }

                return textField.textRange(from: tpos, to: tpos)
        }
    }
}
