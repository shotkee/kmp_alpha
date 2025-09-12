//
//  TextFieldCell.swift
//  AlfaStrah
//
//  Created by Igor Pokrovsky on 18/01/2018.
//  Copyright © 2018 RedMadRobot. All rights reserved.
//

import UIKit
import Legacy

class TextFieldCell: UITableViewCell, UITextFieldDelegate {
    static let id: Reusable<TextFieldCell> = .fromNib()

    var textValue: String? {
        didSet {
            textField.text = textValue
        }
    }

    var inputAccessory: UIView? {
        didSet {
            textField.inputAccessoryView = inputAccessory
        }
    }

    var isLastField: Bool = true {
        didSet {
            textField.returnKeyType = isLastField ? .done : .next
        }
    }

    var validCharacters: [Character]? {
        didSet {
            if preset == .string {
                textField.keyboardType = TextHelper.isAlmostNumeric(validCharacters) ? .numbersAndPunctuation : .default
            }
        }
    }
    var maxCharacters: Int?

    var editingStarted: ((TextFieldCell) -> Void)?
    var editingChanged: ((TextFieldCell) -> Void)?
    var returnKeyTap: ((TextFieldCell) -> Void)?

    @IBOutlet private var textField: UITextField!

    func setHint(_ hint: String, isRequired: Bool) {
        let placeholder = isRequired ? hint + "*" : hint
		textField.attributedPlaceholder = NSAttributedString(
			string: placeholder,
			attributes: [ .foregroundColor: UIColor.Text.textSecondary ]
		)
    }

    enum Preset {
        case number
        case string
        case date
        case time
    }

    var preset: Preset = .string {
        didSet {
            switch preset {
                case .string:
                    textField.keyboardType = TextHelper.isAlmostNumeric(validCharacters) ? .numbersAndPunctuation : .default
                    textChangePreprocess = nil
                case .number:
                    textField.keyboardType = .numbersAndPunctuation
                    textChangePreprocess = nil
                case .date:
                    textField.keyboardType = .numbersAndPunctuation
                    textChangePreprocess = { textField in
                        if let text = textField.text {
                            let mask = SimpleTextMask(format: "[xx].[xx].[xxxx]")
                            let masked = mask.mask(string: text)
                            let valid = RMRSimpleDateFormatter.existingDateInPast(from: masked, separator: ".")
                            textField.text = valid
                        }
                    }
                case .time:
                    textField.keyboardType = .numbersAndPunctuation
                    textChangePreprocess = { textField in
                        if let text = textField.text {
                            let mask = SimpleTextMask(format: "[xx]:[xx]")
                            let masked = mask.mask(string: text)
                            let valid = RMRSimpleDateFormatter.existingTime(from: masked, separator: ":")
                            textField.text = valid
                        }
                    }
            }
        }
    }

    private var textChangePreprocess: ((UITextField) -> Void)?

    func textFieldDidBeginEditing(_ textField: UITextField) {
        editingStarted?(self)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        returnKeyTap?(self)
        return true
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let oldText = (textField.text ?? "") as NSString
        let newText = oldText.replacingCharacters(in: range, with: string)
        if let maxCharacters = maxCharacters, maxCharacters > 0, newText.count > maxCharacters {
            return false
        } else if let validCharacters = validCharacters, !string.isEmpty {
            return validCharacters.contains(where: string.contains)
        }
        return true
    }

    @IBAction func textFieldDidChange(_ textField: UITextField) {
        textChangePreprocess?(textField)

        textValue = textField.text
        editingChanged?(self)
    }
	
	override func awakeFromNib() {
		super.awakeFromNib()

		setupUI()
	}
	
	private func setupUI() {
		if let textField {
			textField.font = Style.Font.text
		}
	}
}
