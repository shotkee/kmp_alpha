//
//  InputInsuranceDataView.swift
//  AlfaStrah
//
//  Created by Stanislav Starzhevskiy on 30.11.2017.
//  Copyright © 2017 RedMadRobot. All rights reserved.
//

import UIKit

class InsuranceDataTextInputView: UIControl, EmptyHintToTopHintBottomValueAnimator, UITextFieldDelegate {
    @IBOutlet private var idleEmptyValueHintLabel: UILabel!
    @IBOutlet private var inputModeTopHintLabel: UILabel!
	@IBOutlet private var textInput: UITextField! {
		didSet {
			textInput.font = Style.Font.headline1
		}
	}

    private var textInputController: TextFieldController?

    var textFieldInput: UITextField {
        textInput
    }

    var emptyHint: UIView {
        idleEmptyValueHintLabel
    }
    var emptySubHint: UIView? {
        nil
    }
    var topHint: UIView {
        inputModeTopHintLabel
    }
    var bottomValue: UIView {
        textInput
    }

    var validCharacters: CharacterSet?
    var maxCharacters: UInt?

    struct Model {
        var isRequired: Bool
        var emptyValueHint: String?
        var attributedEmptyValueHint: NSAttributedString?
        var topHint: String?
        var attributedTopHint: NSAttributedString?
        var bottomHint: String?
        var attributedBottomHint: NSAttributedString?
        var value: String?
        var state: State

        static let empty = Model(isRequired: false, emptyValueHint: nil, attributedEmptyValueHint: nil, topHint: nil,
            attributedTopHint: nil, bottomHint: nil, attributedBottomHint: nil, value: nil, state: .idle)

        enum State {
            case inputMode
            case idle
        }
    }

    private var model = Model.empty {
        didSet {
            update(for: model, oldModel: oldValue)
        }
    }

    var value: String? {
        model.value
    }

    func set(idleEmptyValueHint: String, inputModeTopHint: String, inputModeBottomHint: String?) {
        var newModel = model
        newModel.bottomHint = inputModeBottomHint
        newModel.attributedBottomHint = nil
        newModel.topHint = inputModeTopHint
        newModel.attributedTopHint = nil
        newModel.emptyValueHint = idleEmptyValueHint
        newModel.attributedEmptyValueHint = nil
        model = newModel
    }

    func set(state: Model.State, value: String?) {
        model.state = state
        model.value = value
    }

    func set(inputController: TextFieldController?) {
        textInputController = inputController
    }

    private func update(for newModel: Model, oldModel: Model) {
        if let attributedTop = newModel.attributedTopHint {
            inputModeTopHintLabel.attributedText = attributedTop
        } else {
            inputModeTopHintLabel.text = newModel.topHint
        }

        if let attributedEmpty = newModel.attributedEmptyValueHint {
            idleEmptyValueHintLabel.attributedText = attributedEmpty
        } else {
            idleEmptyValueHintLabel.text = newModel.emptyValueHint
        }

        textInput.placeholder = newModel.bottomHint
        textInput.text = newModel.value

        if newModel.state != oldModel.state {
            switch (newModel.state, oldModel.state) {
                case (.idle, .inputMode):
                    animateToEmptyHint()
                case (.inputMode, .idle):
                    animateToTopHintBottomValue()
                default:
                    break
            }
        }
    }

    @objc private func textValueChanged(sender: UITextField) {
        model.value = sender.text
        sendActions(for: .valueChanged)
        sendActions(for: .editingChanged)
    }

    private lazy var tapGestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapInside))

    override func didMoveToSuperview() {
        super.didMoveToSuperview()

        if var existing = gestureRecognizers, !existing.isEmpty, !existing.contains(tapGestureRecognizer) {
            existing.append(tapGestureRecognizer)
            gestureRecognizers = existing
        } else {
            gestureRecognizers = [ tapGestureRecognizer ]
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        var updatedModel = model
        updatedModel.topHint = inputModeTopHintLabel.text
        updatedModel.attributedTopHint = inputModeTopHintLabelText()
		
        updatedModel.emptyValueHint = idleEmptyValueHintLabel.text
        updatedModel.attributedEmptyValueHint = idleEmptyValueHintLabelAttributedText()

        model = updatedModel

        textInput.delegate = self
        textInput.addTarget(self, action: #selector(textValueChanged(sender:)), for: .editingChanged)
        textInput.addTarget(self, action: #selector(textInputDidEndEditing), for: .editingDidEnd)
        textInput.addTarget(self, action: #selector(textInputDidBeginEditing), for: .editingDidBegin)
    }
	
	private func inputModeTopHintLabelText() -> NSMutableAttributedString {
		let inputModeTopHintLabelText = NSMutableAttributedString()
		
		let titleStyle: [NSAttributedString.Key: Any] = [
			.foregroundColor: UIColor.Text.textSecondary,
			.font: Style.Font.caption1
		]
		
		let titleText = NSMutableAttributedString(
			string: NSLocalizedString("insurance_search_request_insurance_number_input_title_text", comment: "")
		) <~ titleStyle
		inputModeTopHintLabelText.append(titleText)
		
		let highlightedTitleStyle: [NSAttributedString.Key: Any] = [
			.foregroundColor: UIColor.Text.textAccent,
			.font: Style.Font.caption1
		]
		
		let highlightedTitleText = NSMutableAttributedString(
			string: NSLocalizedString("insurance_search_request_insurance_number_input_title_highlighted_text", comment: "")
		) <~ highlightedTitleStyle
		inputModeTopHintLabelText.append(highlightedTitleText)

		return inputModeTopHintLabelText
	}
	
	private func idleEmptyValueHintLabelAttributedText() -> NSMutableAttributedString {
		let idleEmptyValueHintLabelAttributedText = NSMutableAttributedString()
		
		let titleStyle: [NSAttributedString.Key: Any] = [
			.foregroundColor: UIColor.Text.textPrimary,
			.font: Style.Font.text
		]
		
		let titleText = NSMutableAttributedString(
			string: NSLocalizedString("insurance_search_request_insurance_number_input_title_text", comment: "")
		) <~ titleStyle
		idleEmptyValueHintLabelAttributedText.append(titleText)
		
		let highlightedTitleStyle: [NSAttributedString.Key: Any] = [
			.foregroundColor: UIColor.Text.textAccent,
			.font: Style.Font.text
		]
		
		let highlightedTitleText = NSMutableAttributedString(
			string: NSLocalizedString("insurance_search_request_insurance_number_input_title_highlighted_text", comment: "")
		) <~ highlightedTitleStyle
		idleEmptyValueHintLabelAttributedText.append(highlightedTitleText)
		
		let placeholderStyle: [NSAttributedString.Key: Any] = [
			.foregroundColor: UIColor.Text.textSecondary,
			.font: Style.Font.caption1
		]
		
		let placeholderText = NSMutableAttributedString(
			string: NSLocalizedString("insurance_search_request_insurance_number_input_placeholder_text", comment: "")
		) <~ placeholderStyle
		idleEmptyValueHintLabelAttributedText.append(placeholderText)
		
		return idleEmptyValueHintLabelAttributedText
	}
	
    @objc func textInputDidEndEditing() {
        sendActions(for: .editingDidEnd)

        if textInput.text?.isEmpty ?? true {
            set(state: .idle, value: nil)
        }
    }

    @objc func textInputDidBeginEditing() {
        sendActions(for: .editingDidBegin)
    }

    @IBAction func tapInside() {
        set(state: .inputMode, value: model.value)
        if !textInput.isFirstResponder {
            textInput.becomeFirstResponder()
        }
    }

    func cancelEditing() {
        if textInput.text?.isEmpty ?? true {
            set(state: .idle, value: nil)
        }

        textInput.resignFirstResponder()
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text as NSString? else { return false }

        if let maxCharacters = maxCharacters, maxCharacters > 0, text.replacingCharacters(in: range, with: string).count > maxCharacters {
            return false
        } else if let validCharacters = validCharacters, !string.isEmpty {
            return CharacterSet(charactersIn: string).isSubset(of: validCharacters)
        }

        return true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
