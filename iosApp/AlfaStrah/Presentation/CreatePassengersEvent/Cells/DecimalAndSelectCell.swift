//
//  DecimalAndSelectCell.swift
//  AlfaStrah
//
//  Created by Igor Pokrovsky on 16/01/2018.
//  Copyright © 2018 RedMadRobot. All rights reserved.
//

import UIKit
import Legacy

class DecimalAndSelectCell: UITableViewCell, UITextFieldDelegate {
    static let id: Reusable<DecimalAndSelectCell> = .fromNib()

    var textValue: String? {
        didSet {
            textField.text = textValue
            dataChangedCallback?(textValue, selectValue)
        }
    }

    var selectValue: String? {
        didSet {
            selectButton.setTitle("\(selectValue ?? "")  ▼", for: .normal)
            dataChangedCallback?(textValue, selectValue)
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

    var options: [String] = []

    var validCharacters: [Character]?
    var maxCharacters: Int?

    var editingStarted: ((DecimalAndSelectCell) -> Void)?
    var returnKeyTap: ((DecimalAndSelectCell) -> Void)?
    var showOptionsCallback: (() -> Void)?

    var dataChangedCallback: ((String?, String?) -> Void)?

    @IBOutlet private var textField: UITextField!
    @IBOutlet private var selectButton: UIButton!

    @IBAction private func selectButtonTap() {
        showOptionsCallback?()
    }

    func showHint(_ hint: String, isRequired: Bool) {
        let placeholder = isRequired ? hint + "*" : hint
        textField.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [ .foregroundColor: UIColor.lightGray ])
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        editingStarted?(self)
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text as NSString? else { return false }

        if let maxCharacters = maxCharacters, maxCharacters > 0, text.replacingCharacters(in: range, with: string).count > maxCharacters {
            return false
        } else if let validCharacters = validCharacters, !string.isEmpty {
            return validCharacters.contains(where: string.contains)
        }
        return true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        returnKeyTap?(self)
        return true
    }

    @IBAction func textFieldDidChange(_ textField: UITextField) {
        textValue = textField.text
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
